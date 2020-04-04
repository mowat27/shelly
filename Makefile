.PHONY: test 
test:
	test/start.sh /code/test -t -r || true

sandbox:
	docker run -it --rm ubuntu /bin/bash