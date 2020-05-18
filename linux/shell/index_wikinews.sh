# /bin/bash
wget https://github.com/bharvidixit/mastering-elasticsearch-5.0/blob/master/chapter-5/enwikinews-20160926-cirrussearch-content.json.gz
export dump=enwikinews-20160926-cirrussearch-content.json.gz
export index=wikinews

mkdir chunks
cd chunks
zcat ../$dump | split -a 10 -l 500 - $index
export es=localhost:9200
for file in *; do
	#statements
	echo -n "${file}: "
	took=$(curl -s -XPOST $es/$index/_bulk?pretty --data-binary @$file | grep)
done