#author: fazlerabbi37

#shell script name: gitea_installer.sh 

#the purpose of the shell script is to install Gitea

#!/bin/bash


#be sudo
sudo -v

#check for git version if not found install git
if [[ -z $(git --version | awk '{print $3}') ]]
then
    sudo apt install -y git
fi

#create user to run Gitea
sudo adduser --system --shell /bin/bash --gecos 'Git Version Control' --group --disabled-password --home /home/git git

#create required directory structure
sudo mkdir -p /var/lib/gitea/{custom,data,indexers,public,log}
sudo chown git:git /var/lib/gitea/{data,indexers,log}
sudo chmod 750 /var/lib/gitea/{data,indexers,log}
sudo mkdir /etc/gitea
sudo chown root:git /etc/gitea
sudo chmod 770 /etc/gitea


#database installation
sudo -v
sudo apt update
sudo apt install -y postgresql postgresql-contrib

#ask user if he wants to create a user
echo "Do you want to create a PostgreSQL user?[y/n]"
read option
if [[ $option == 'y' ]]
then
    echo "Creating new superuser..."
    read -p "Enter PostgreSQL user name: " psql_username
    sudo -u postgres createuser -slPW $psql_username
else
    echo "Enter the PostgreSQL user name that will be used for creating database:"
    read psql_username
fi

#create gitea database
echo "Creating new gitea database..."
sudo -u postgres createdb -E UTF8 -O $psql_username gitea

#ask user for Gitea version
echo "Enter the version of Gitea you want to install[x.y.z]:"
read gitea_version
echo ""
#ask user for Gitea OS and architecture
echo "Enter your OS and architecture[linux-amd64, linux-arm-6, windows-4.0-amd64.exe]:"
read gitea_os_arch

#download Gitea
wget -O gitea https://dl.gitea.io/gitea/$gitea_version/gitea-$gitea_version-$gitea_os_arch

#copy gitea binary and make executable
sudo cp gitea /usr/local/bin/gitea
sudo chmod +x /usr/local/bin/gitea
rm gitea

#create gitea service
sudo wget -O /etc/systemd/system/gitea.service https://raw.githubusercontent.com/go-gitea/gitea/master/contrib/systemd/gitea.service

#uncomment 'After=postgresql.service'
sudo sed -i '/#After=postgresql.service/c\After=postgresql.service' /etc/systemd/system/gitea.service 

#enable Gitea at boot and start Gitea
sudo systemctl enable gitea
sudo systemctl start gitea

#go to web browser
echo "Now head to http://server_ip:3000 address with your browser to finish installation."


