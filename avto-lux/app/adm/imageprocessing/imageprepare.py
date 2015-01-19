# import PIL
# from PIL import Image

# from app.configparser import config


# def resize_images(images):
# 	for image in images:
# 		img = Image.open(image['path'])
# 		imgs = []
# 		sizes = config('IMAGE_SIZES')

# 		for size in calculate_sizes(img.size):

# 			img = img.resize(size, resample=PIL.Image.BICUBIC)
# 			img.save(image['path'])

# 			# imgs.append[]
# 			yield imgs


# def calculate_sizes(image_size, sizes):
# 	size_ratio = (float(image_size[1]) / float(image_size[0]))
# 	for item in sizes:
# 		yield {
# 			'prefix':(item + '_').lower(),
# 			'size': (sizes[item], int(sizes[item] * size_ratio))
# 		}
