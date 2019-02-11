# How to setup an ELK instance with UForge

## Prerequisites

* UForge AppCenter (at least version 3.8FP9) (you can use https://uforge.usharesoft.com/uforge/)
* Hammr (same version than UForge, documentation available here http://docs.usharesoft.com/projects/hammr/en/latest/) (```pip install hammr```)
* A server to run the ELK instance (at least 4Ghz CPU and 8Gb RAM recommended)

The amount of CPU, RAM, and storage that the ELK Server depends on the volume of logs. The previous configuration is suitable for analyzing 10 logs files having an output of 100 lines per second.

## 1. Import ELK template inside UForge

### 1.1 Set Hammr credentials
Make sure to set your hammr credentials inside ```~/.hammr/credentials.json```:

```json
{
  "user" : "YOUR_USER",
  "password" : "YOUR_PASSWORD",
  "url" : "YOUR_FORGE_URL/api",
  "acceptAutoSigned": true
}
```

Verify everything is ok by running the ```hammr template list``` command once.

### 1.2 Set a root access

Edit the file `./build-hammr/template-elk-uforge.yml` to set a root access.
Either specify an sshKey (recommended) or set a root password.

```bash
vi ./build-hammr/template-elk-uforge.yml
```

* Using an sshKey:

  In `rootUser` section, uncomment the lines `sshKeys`, `password` and `setPassword` and add your ssh key.

* Using a password:

    In `rootUser` section, uncomment the lines `password` and `setPassword` and choose a password.


### 1.3 Import the template into your forge
Launch the script to create your appliance:

```bash
./build-hammr/create-template.sh
```
This script creates a UForge template for an ELK server, and imports it directly to UForge.

## Deploy your ELK instance

Using UForge, generate and publish your appliance to any target cloud you want to use.
Then either deploy with blueprint or manually.

### Deploying with blueprint (for AWS only)

If your UForge user has blueprint rights granted, you can easily deploy your ELK instance using blueprint.

In the blueprint section, create a new blueprint containing only your appliance.
Set the following template configuration:
* Min Cores: 4
* Min Memory: 8192
* Extra configuration:
```yaml
brooklyn.config:
    kibana.port: 5601
    logstash.port: 5044
```

Deploy your blueprint and your instance will be up and running.

### Deploying manually

Once your appliance is published.
1. Start it manually, specifying all required configurations
2. Connect to it using SSH
3. Open port 5601 and 5044:
```bash
ssh USER@ELK_SERVER_IP iptables -A INPUT -p tcp --dport 5044 -j ACCEPT
ssh USER@ELK_SERVER_IP iptables -A INPUT -p tcp --dport 5601 -j ACCEPT
```

## Accessing your ELK instance

When your instance is up and running open a browser and go to `<ELK_SERVER_IP>:5601`.

