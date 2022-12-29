docker kill pgplaygrd_cntr

#docker build . --progress=plain  --no-cache -t wiwwo:pgplaygrd
docker build .  -t wiwwo:pgplaygrd

docker run --name pgplaygrd_cntr  -d --rm wiwwo:pgplaygrd
docker exec -it pgplaygrd_cntr  bash

# docker kill pgplaygrd_cntr
echo;echo  docker kill pgplaygrd_cntr
