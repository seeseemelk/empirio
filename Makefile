.PHONY: all
all: backend frontend

.PHONY: backend
backend:
	dub build

.PHONY: frontend
frontend:
	npm run build

.PHONY: run
run: all
	./empirio

.PHONY: clean
clean:
	dub clean
	rm -f public/empirio.js public/empirio.js.map
