# -*- coding: utf-8 -*-

def run_upload_files_gc():
	
	print('GC is running...')
	
	
	from app.configparser import config
	from app.models.dbconnect import Session
	from app.models.catalogmodels import (CatalogSectionModel, CatalogItemModel)
	from app.models.pagemodels import StaticPageModel
	from os import listdir, path, remove
	
	
	files = []
	had_error = False
	session = Session()
	
	def get_paths_from_list(items):
		items = sum(items, []) # flatten
		items = [x['filename'] for x in items]
		return items
	
	def get_files(items):
		items = [x.system_files_list for x in items]
		items = get_paths_from_list(items)
		return items
	
	result = session.query(CatalogSectionModel).all()
	files += get_files(result)
	
	result = session.query(CatalogItemModel).all()
	files += get_files(result)
	files += get_paths_from_list([x.system_images for x in result])
	for item in result:
		if item.system_main_image is not None:
			files.append(item.system_main_image['filename'])
	
	result = session.query(StaticPageModel).all()
	files += get_files(result)
	
	session.close()
	
	
	uploaded_files = list(filter(
		lambda x: path.isfile(path.join(config('UPLOAD_FILES_PATH'), x)),
		listdir(config('UPLOAD_FILES_PATH'))
	))
	collected_list = list(filter(
		lambda x: x not in files,
		uploaded_files
	))
	
	for garbage_file in collected_list:
		remove(path.join(config('UPLOAD_FILES_PATH'), garbage_file))
	
	
	separator = '\n    '
	collected_str = \
		' nothing' if len(collected_list) < 1 \
		else separator + separator.join(collected_list)
	
	
	print(
		'GC is done!\n' + \
		'  Total in database: %d\n' % len(files) + \
		'  Total in uploaded files directory: %d\n' % len(uploaded_files) + \
		'  Removed from uploaded files directory (%d):%s' % (len(collected_list), collected_str)
	)
