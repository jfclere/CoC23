AC2014scripts
=============

Script to do the tests used to fill the data of ApacheCon 2014 presentation.

To create the files used for the test: in script
mkdatafiles.sh

To run the tests: in scripts.
bash runalltests.sh /tmp/reports 300 5 localhost 8000
where
/tmp/reports is the directory to create the reports.
300 is the timeout for ab
5 is the time between the tests.
localhost is the hostname of the box to test = where tomcat is running.
8000 is the port of httpd (we are comparing to httpd).

To analyse the results: (requires perl)
gather_results.sh filename.txt /tmp/reports
where
filename.txt is the output text file with the results.
/tmp/reports is the directory where the reports are created.

output format:
Transfer rate   filename (file size) (4KiB = 4 x 1024 bytes) and transfert in [Kbytes/sec]
12112.37        4KiB.bin
22066.28        8KiB.bin
38160.77        16KiB.bin
58951.41        32KiB.bin
