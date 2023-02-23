import os
for i in range(10000):
	file_name = f"foo{i}.txt"
	file_size = 2*1024*1024 #size in Bytes
	with open(file_name, "wb") as f:
		f.write(os.urandom(file_size))
