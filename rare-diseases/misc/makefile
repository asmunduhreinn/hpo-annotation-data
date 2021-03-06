#
# Makefile to generate a release of the HPO-annotation data
#
# Authors: Sebastian Koehler (sebastian.koehler@charite.de)
# Date   : 2012-09-24


NOW := $(shell date +"%Y-%m-%d %H:%M")

# the programs being called
GENERATE_ANNOTATIONFILE=java -Xmx1G -jar jarFiles/generateAnnotationFile.jar


# the folders where external data is stored locally
EXTERNAL_ORPHANET?=external_orphanet
ORPHANET_MAPPING?=orphanetmapping
HPO_FOLDER?=hpo


##### 
# note that the ordering is important here!! 
# first update the annotation file! than the rest!!!
.PHONY: all
all: load-external generate-annotation-file

# load external data
.PHONY: load-external
load-external:
	# load orphanet data
	mkdir -p $(EXTERNAL_ORPHANET)
	# Employ wget to retrieve all external ontologies as specified
	# in external_ontologies. We also ignore lines starting with #
	#cd $(EXTERNAL_ORPHANET) ; cat ../external_orphanet.txt | sed "/^#.*$$/d" | wget --retry-connrefused -N -i -
	cd $(EXTERNAL_ORPHANET) ; aria2c --max-connection-per-server=4 --min-split-size=1M -i ../external_orphanet.txt
	# loads the mapping between orphanet's signs-and-symptoms and HPO
	svn --force export http://compbio.charite.de/svn/hpo/trunk/src/mappings/ $(ORPHANET_MAPPING)
	# loads the HPO
	#wget -N -P $(HPO_FOLDER) http://compbio.charite.de/hudson/job/hpo/lastSuccessfulBuild/artifact/hp/hp.obo
	aria2c --max-connection-per-server=4 --min-split-size=1M http://compbio.charite.de/hudson/job/hpo/lastSuccessfulBuild/artifact/hp/hp.obo
	mkdir -p $(HPO_FOLDER)
	mv hp.obo $(HPO_FOLDER)/human-phenotype-ontology.obo
	#svn --force export http://compbio.charite.de/svn/hpo/trunk/src/ontology/ $(HPO_FOLDER)



# takes the manual-annotations (stored at berkeley) and the orpha-data files and generates a big integrated file of HPO-annotated diseases
.PHONY: generate-annotation-file
generate-annotation-file:
	$(GENERATE_ANNOTATIONFILE) --orphadata "$(EXTERNAL_ORPHANET)" --sign-mapping "$(ORPHANET_MAPPING)/onet_hpo.tsv" --out-folder "." --hpo_ontology "$(HPO_FOLDER)" --berkeley-annotated "../annotated/"
	cat phenotype_annotation.tab negative_phenotype_annotation.tab | awk -F'\t' '{print $$14}'  | sort | uniq -c | sort -nr > curator-statistics.tab
	echo "$(NOW)" > data_version.txt

.PHONY: clean
clean:
	rm -Rf $(EXTERNAL_ORPHANET)
	rm -Rf $(BERKELEY_ANNOT)
	rm -Rf $(BERKELEY_ANNOT_REFORMAT)
