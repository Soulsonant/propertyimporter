README

# 1.  INSTALLATION

git clone https://github.com/Soulsonant/propertyimporter
cd propertyimporter

bundle install 

export DB_USERNAME=tk
export DB_PASSWORD=tk
export DB_HOST=localhost

rails db:create db:migrate
rails s


# 2. TECHNICAL THOUGHTS/TRADEOFFS: 
	Originally used a separate table to hold the import, which would be more ideal if the data is being stored and modified and expected to be imported.  Opted to use session info instead - does limit to one import at a time but much less transaction heavy - will be somewhat easier to edit lines in the future if user notices an issue.   Does introduce a size limit (somewhere around 4k?).  Obviously this could be an issue for very large files but that seems like a bigger challenge to tackle.
	I wanted to assign unique names to properties as well, but ended up just using the "building name." There would be issues with my code from this standpoint (what if same name but different street address?), etc. 
	Unit really stumped me because I wanted to call out only integers but realized units could be alphanumeric (or worse) so very little validation happens currently in that cell.
	Ideally would check zip code vs city name to see if any immediate issues (eg last row in example).  (use zip_codes gem)
	I did checking for completely duplicated rows and similar for building names for the units table, but need a lot more duplication validation in the long term (name + address, etc)
	Using built in CSV lib instead of csv-importer was easier but lacks opportunity for better error throwing early in the csv import
	No in-line editing at this point - easier if i was using a staging table
	

# 3. WHAT I'D WORK ON NEXT:
	Input from stakeholders - pain points, ways to improve, etc.
	Edit button inside my form to immediately fix errors before importing.
	Force button to push something even if it had an error of some kind
	Check for zip code/city validation using gem zip_codes
	Make it looks way nicer
	More validation checks.  internal tool but very little security around injects or bad characters beyond what i've already checked for. 
	More duplication checks.  


# 4. Final Thoughts:
	Domain understanding what the needs of the team are and what some real world examples might look like that have caused issues would be good for future development.  (Units variability, naming properties, etc)
