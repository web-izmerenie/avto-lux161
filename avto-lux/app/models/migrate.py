# -*- coding: utf-8 -*-

import re
from os import path, listdir
from operator import itemgetter

from .dbconnect import Session
from app.configparser import config


_revision_table              = config('DATABASE')['TABLE_NAME_PREFIX'] + 'migrate_revision'
_get_revision_query          = "SELECT version FROM %s;" % _revision_table
_create_revision_table       = "CREATE TABLE %s (version integer NOT NULL);" % _revision_table
_add_revision_record         = "INSERT INTO %s (version) VALUES (0);" % _revision_table
_migration_file_name_pattern = re.compile('^migration_r([0-9]+)_to_r([0-9]+).sql$')


def _get_revision_records(session=None):
	s = session if session is not None else Session()
	try:
		records = s.execute(_get_revision_query)
		return records
	finally:
		if session is None:
			s.close()

def _get_current_revision(records):
	elements = records.fetchall()
	assert len(elements) == 1, "Expected migration revision records count to be '1'"
	prev_version = dict(elements[0].items())['version']
	assert type(prev_version) is int, "Expected migration revision to be 'int'"
	return prev_version

def _set_migration_revision(new_revision_version, session=None):
	
	assert type(new_revision_version) is int
	prev_version = _get_current_revision(_get_revision_records())
	
	s = session if session is not None else Session()
	
	s.execute("UPDATE %s SET version = %d WHERE version = %d" % (
		_revision_table, new_revision_version, prev_version
	))
	s.commit()
	
	if session is None: s.close()

def _init_storage(session=None):
	
	s = session if session is not None else Session()
	
	# creating table
	s.execute(_create_revision_table)
	s.commit()
	
	# creating revision record
	s.execute(_add_revision_record)
	s.commit()
	
	if session is None: s.close()

def _get_migrations():
	
	def f(entry_name):
		entry_path = path.join(migrations_dir, entry_name)
		entry_match = _migration_file_name_pattern.match(entry_name)
		return {
			'path' : entry_path,
			'from' : int(entry_match.group(1)),
			'to'   : int(entry_match.group(2))
		} if path.isfile(entry_path) and entry_match is not None else None
	
	migrations_dir = path.join('avto-lux', 'migrations')
	migrations = [x for x in map(f, listdir(migrations_dir)) if x is not None]
	return sorted(migrations, key=itemgetter('from'))


def get_migration_revision():
	
	records = None
	try:
		records = _get_revision_records()
	except Exception as e:
		if ('relation "%s" does not exist' % _revision_table) in str(e):
			print(
				("Migration revision table '%s' does not exist.\n" % _revision_table) + \
				"It means that it is 'r9'.\n" + \
				("Creating migration revision table '%s' " % _revision_table) + \
				"and saving '9' revision version as current."
			)
			
			s = Session()
			
			_init_storage(session=s)
			
			# set current revision to '9'
			_set_migration_revision(9, session=s)
			
			records = _get_revision_records(session=s)
			
			s.close()
		else:
			raise e
	
	return _get_current_revision(records)

def migrate(session=None):
	
	revision = get_migration_revision()
	print('Current revision:', revision)
	
	def f(x):
		x = x.copy()
		fd = open(x['path'], 'r')
		x['sql'] = ''.join(fd.readlines())
		fd.close()
		return x
	found_revision = [f(x) for x in _get_migrations() if x['from'] == revision]
	assert len(found_revision) in [0, 1]
	found_revision = found_revision[0] if len(found_revision) == 1 else None
	
	if found_revision is None:
		print("All migrations is applied, no need to do anything.")
	else:
		print("Migrating from '%d' to '%d'..." % (
			found_revision['from'], found_revision['to']
		))
		
		s = Session()
		
		s.execute(found_revision['sql'])
		s.commit()
		
		_set_migration_revision(found_revision['to'], session=s)
		
		print("Migration from '%d' to '%d' is complete." % (
			found_revision['from'], found_revision['to']
		))
		
		# recursive
		migrate(session=s)
		
		if session is None: s.close()

# to store last migration version
# if project started with new empty database
def init_migrate():
	
	last_revision = _get_migrations()[-1]['to']
	
	s = Session()
	
	_init_storage(session=s)
	
	print("Saving '%d' as last migration revision...." % last_revision)
	_set_migration_revision(last_revision, session=s)
	
	s.close()
