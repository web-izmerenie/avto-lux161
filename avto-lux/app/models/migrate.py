# -*- coding: utf-8 -*-

from .dbconnect import Session
from app.configparser import config
from os import (path, listdir)
import re

_revision_table              = config('DATABASE')['TABLE_NAME_PREFIX'] + 'migrate_revision'
_get_revision_query          = "SELECT version FROM %s;" % _revision_table
_create_revision_table       = "CREATE TABLE %s (version integer NOT NULL);" % _revision_table
_add_revision_record         = "INSERT INTO %s (version) VALUES (0);" % _revision_table
_migration_file_name_pattern = re.compile('^migration_r([0-9]+)_to_r([0-9]+).sql$')

def _get_revision_records():
	s = Session()
	try:
		records = s.execute(_get_revision_query)
		return records
	finally:
		s.close()

def _get_current_revision(records):
	elements = records.fetchall()
	assert len(elements) == 1, "Expected migration revision records count to be '1'"
	prev_version = dict(elements[0].items())['version']
	assert type(prev_version) is int, "Expected migration revision to be 'int'"
	return prev_version

def _set_migration_revision(new_revision_version):
	assert type(new_revision_version) is int
	prev_version = _get_current_revision(_get_revision_records())
	
	s = Session()
	s.execute("UPDATE %s SET version = %d WHERE version = %d" % (
		_revision_table, new_revision_version, prev_version
	))
	s.commit()
	s.close()

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
			
			# creating table
			s = Session()
			s.execute(_create_revision_table)
			s.commit()
			s.close()
			
			# creating revision record
			s = Session()
			s.execute(_add_revision_record)
			s.commit()
			s.close()
			
			# set current revision to '9'
			_set_migration_revision(9)
			
			records = _get_revision_records()
		else:
			raise e
	
	return _get_current_revision(records)

def migrate():
	revision = get_migration_revision()
	print('Current revision:', revision)
	migrations_dir = path.join('avto-lux', 'migrations')
	found_revision = None
	for entry_name in listdir(migrations_dir):
		entry_path = path.join(migrations_dir, entry_name)
		entry_match = _migration_file_name_pattern.match(entry_name)
		if path.isfile(entry_path) \
		and entry_match is not None \
		and int(entry_match.group(1)) == revision:
			fd = open(entry_path, 'r')
			found_revision = {
				'name' : entry_name,
				'path' : entry_path,
				'from' : int(entry_match.group(1)),
				'to'   : int(entry_match.group(2)),
				'sql'  : ''.join(fd.readlines())
			}
			fd.close()
			break
	if found_revision is None:
		print("All migrations is applied, no need to do anything.")
	else:
		print("Migrating from '%d' to '%d'..." % (
			found_revision['from'], found_revision['to']
		))
		
		s = Session()
		s.execute(found_revision['sql'])
		s.commit()
		s.close()
		
		_set_migration_revision(found_revision['to'])
		
		print("Migration from '%d' to '%d' is complete." % (
			found_revision['from'], found_revision['to']
		))
		
		# recursive
		migrate()
