# **FortiGate Cleanup Script**

This Bash script automates the cleanup of old entries on a FortiGate firewall by processing a list of IP addresses and releasing them using a specified Python script.

---

## **Features**
- Reads IP entries from a file (`ips_list.txt`).
- Extracts IP addresses matching a specific pattern (`Block-<IP>-SOC`).
- Executes a Python command to release each IP on the FortiGate.
- Logs the process to a file (`logs/cleanup.log`), including success and failure messages.
- Skips invalid entries gracefully.

---

## **Requirements**
### **System Requirements**
- Bash shell (Linux/MacOS/WSL).
- Python 3 installed on the system.
- Access to the FortiGate API.

### **Dependencies**
- A Python script named `forti.py` with the following command-line options:
  - `--user`: API token or username.
  - `--pwd`: Password.
  - `--host`: FortiGate IP or hostname.
  - `--direction`: Traffic direction (e.g., `Inbound`).
  - `--in_group`: Group name (e.g., `BlockIP`).
  - `--targetip`: Target IP to release.
  - `--action`: Action to perform (e.g., `release`).

---

## **Setup Instructions**
1. Clone the repository:
   ```bash
   git clone https://github.com/olugbedu/bash-script-fortigate-cleanup.git
   cd bash-script-fortigate-cleanup
   ```

2. Ensure the following files are present:
   - `fortigate_cleanup.sh` (the main script).
   - `ips_list.txt` (input file with entries to process).
   - `forti.py` (Python script for FortiGate interactions).

3. Make the script executable:
   ```bash
   chmod +x cleanup.sh
   ```

4. Prepare the input file (`ips_list.txt`) with entries in the format:
   ```
   Block-192.168.1.1-SOC
   Block-10.0.0.5-SOC
   InvalidEntryWithoutIP
   ```

---

## **Usage**
1. Run the script:
   ```bash
   ./fortigate_cleanup.sh
   ```

2. The script performs the following steps:
   - Checks for the existence of the input file (`ips_list.txt`).
   - Reads each line from the file and extracts valid IPs.
   - Executes the `forti.py` script to release the IP on the FortiGate.
   - Logs all actions to `logs/fortigate_cleanup.log`.

3. Check the log file for detailed output:
   ```bash
   cat logs/fortigate_cleanup.log
   ```

---

## **How It Works**
1. **Initialize Variables**:
   - Defines paths for the input file, log directory, and log file.
   - Ensures the log directory exists.

2. **Log Messages**:
   - Logs timestamps and messages for each step in the process.

3. **Log Levels**:
   - Indicates logs level (INFO, ERROR)

4. **Extract IPs**:
   - Uses a regex pattern to extract IPs matching `Block-<IP>-SOC`.

5. **Process Entries**:
   - Executes the Python command with the extracted IP as an argument.
   - Logs success or failure for each IP.

6. **Error Handling**:
   - Skips invalid entries and logs the error.
   - Exits gracefully if the input file is missing.

---

## **Example Output**
### **Input File (`ips_list.txt`)**
```
Block-192.168.1.1-SOC
Block-10.0.0.5-SOC
InvalidEntryWithoutIP
```

### **Log File (`logs/fortigate_cleanup.log`)**
```
2025-01-09 10:00:00 - Script started.
2025-01-09 10:00:01 - Executing: python3 forti.py --user apitoken --pwd xxx --host 123.123.123.123 --direction Inbound --in_group BlockIP --targetip 192.168.1.1 --action release
2025-01-09 10:00:02 - Successfully processed IP: 192.168.1.1
2025-01-09 10:00:03 - Executing: python3 forti.py --user apitoken --pwd xxx --host 123.123.123.123 --direction Inbound --in_group BlockIP --targetip 10.0.0.5 --action release
2025-01-09 10:00:04 - Successfully processed IP: 10.0.0.5
2025-01-09 10:00:05 - Skipping invalid entry: InvalidEntryWithoutIP
2025-01-09 10:00:06 - Script completed.
```

---

## **Troubleshooting**
- **Input File Not Found**: Ensure `ips_list.txt` exists in the same directory as the script.
- **Python Script Errors**: Verify that `forti.py` is functional and has the correct permissions.
- **Invalid Entries**: Review and fix the entries in the input file if necessary.

---

## **Contributing**
Feel free to contribute to this project! Submit a pull request with your proposed changes.
