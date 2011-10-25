The original map2slim script (using GO:: from perl)
needed nearly two minutes on a 2 GHz Intel Core to
read in a 19 MB GO.obo file and associate 5,800 GO
annotations with it. At the end, more than 200 MB of
memory were allocated. - The Objective-C code loads GO
from cache in 0.4 seconds, and from slow disk in a few
seconds. The GO itself takes not more than 18 MB. GO
annotations space is released after slim making.

NOTE: this is a hack! It might break with involved ontologies.

GOA parser requirements:
- GAF 1 and GAF 2.
- handle gzip/bzip files

Requirements for slim generator:
- optionally leave out definitions
- intersections between any number of GOA files

Requirements for the slim stat generator:
- gen both full stats, and stats on leaves only
