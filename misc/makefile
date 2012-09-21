#
# Makefile to generate a release of the HPO-annotation data
#
# Authors: Sebastian Koehler (sebastian.koehler@charite.de)
# Date   : 2012-09-21


# the programs being called
GENERATE_ANNOTATIONFILE=java -Xmx1G -jar jarFiles/generateHpoAnnotationFile.jar


# the folders where external data is stored locally
EXTERNAL_ORPHANET?=external_orphanet
BERKELEY_ANNOT?=annotated
ORPHANET_MAPPING?=orphanetmapping


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
	cd $(EXTERNAL_ORPHANET) ; cat ../external_orphanet.txt | sed "/^#.*$$/d" | wget --retry-connrefused -N -i -
	# loads the mapping between orphanet's signs-and-symptoms and HPO
	svn export http://compbio.charite.de/svn/hpo/trunk/src/mappings/ $(ORPHANET_MAPPING)


# takes the manual-annotations (stored at berkeley) and the orpha-data files and generates a big integrated file of HPO-annotated diseases
.PHONY: generate-annotation-file
generate-annotation-file:
	$(UPDATEFROMBERKELEY) --ncbidata "$(EXTERNAL_NCBI)" --orphadata "$(EXTERNAL_ORPHANET)" --sign-mapping "$(ORPHANET_MAPPING)/onet_hpo.tsv" --out-file "new_annot.txt" --hpo_ontology "../" --berkeley-annotated $(BERKELEY_ANNOT_REFORMAT)
		

.PHONY: clean
clean:
	rm -Rf $(EXTERNAL_ORPHANET)
	rm -Rf $(BERKELEY_ANNOT)
	rm -Rf $(BERKELEY_ANNOT_REFORMAT)
