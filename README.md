# archive-media
process media files, compress video and photos, and tar to store in archive


My folder structure:

* 2001/01-jan/
* 2001/02-feb/somerandomdir
* 2001/03-mar/
* 2001/04-apr/
* 2001/05-may/somerandomdir
* 2001/06-jun/
* 2002/01-jan/
* 2002/02-feb/somerandomdir1/somerandomdir2

### Usage

#### If file resides in root folder of library

<pre>
sh ./optimize.sh 
</pre>

#### Can run from anywhere and call full directory path

<pre>
sh ./optimize.sh "starting dir"
</pre>