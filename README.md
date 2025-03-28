## **Project Update Scripts**  

This repository contains shell scripts for managing and deploying projects based on a configuration file.  

### 📂 **Files**  

- `update_projects.sh` – Reads a configuration file and processes multiple projects (cloning/updating repositories, handling dependencies, etc.).  
- `update_container.sh` – Manages project containers and updates their settings.  

### 📄 **Configuration File (`projects.txt`)**  

The script expects a `projects.txt` file formatted as follows:  

```txt
project_name;github_url;folder_name;port
```

- `project_name` – Name of the project.  
- `github_url` – GitHub repository URL.  
- `folder_name` – Directory where the project will be stored.  
- `port` – Desired port for running the project.  

### 🚀 **Usage**  

1. **Make scripts executable**:  
   ```bash
   chmod +x update_projects.sh update_container.sh
   ```
   
2. **Copy the script folder to the root folder of the desired projects**

3. **Run the project update script**:  
   ```bash
   ./update_projects.sh
   ```  

### 🛠 **Requirements**  

- Linux/macOS environment with `bash` installed.  
- Git installed for cloning repositories.  
- Additional dependencies may be required based on the projects being deployed.
