stop:
	@if [ -n "$$(docker ps -a -q)" ]; then docker stop $$(docker ps -a -q); fi

remove:
	@if [ -n "$$(docker ps -a -q)" ]; then docker rm $$(docker ps -a -q); fi

run:
	docker run -p 8080:80 myapp

build:
	docker build -t myapp .

clean: stop remove

