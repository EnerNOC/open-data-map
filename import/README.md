# Data Import Instructions

Have Redis > 2.6 Installed Node/NPM and `coffee-script`

Download and extract then ENOC 2012 data to this directory, and run the import.
Note the script doesn't exit when finished, but you'll see it stop and all sites 
will reach a count of > 105000

    wget https://open-enernoc-data.s3.amazonaws.com/anon/csv-only.tar.gz
    tar -xzf csv-only.tar.gz
    coffee etl.coffee

Note it's strongly recommended you add a `save ""` directive to redis.conf so 
everything stays in memory
