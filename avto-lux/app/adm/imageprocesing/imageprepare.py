from PIL import Image
from app.configparser import config

def resize_image(path):
	img = Image.open(path)
	img.resize(size, resample=None)
	img.save()
	yield img


def save_images_permanently():
	pass


def save_images_temporary(files):
	for file in files:
		create_file_name(file)
		f = open(config('IMAGE_TMP_PATH') + file_name, )
	yield path


def create_file_name(file):
	pass

