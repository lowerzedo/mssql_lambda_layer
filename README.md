### Make script executable

chmod +x create-mssql-layer.sh

### Run it:

./create-mssql-layer.sh

---

### The script will:

- Create the necessary directory structure
- Install the MSSQL ODBC driver and its dependencies
- Install pyodbc and its dependencies
- Package everything into a ZIP file called mssql-layer.zip

---

### Then, to create the Lambda layer:

- Go to AWS Lambda console
- Navigate to Layers
- Click "Create layer"
- Upload the mssql-layer.zip file
- Select Python 3.10 as the compatible runtime
- Create the layer
