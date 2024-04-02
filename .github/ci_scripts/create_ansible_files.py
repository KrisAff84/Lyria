import os

inventory_path = '../../ansible/inventory'
config_path = '../../ansible/ansible.cfg'
remote_user = 'ubuntu'
web_server_ip = os.environ.get('STAGING_SERVER_IP')
private_key = os.environ.get('SSH_KEY')

with open(inventory_path, 'x') as f:
    f.write('[staging]\n')
    f.write(web_server_ip)

with open(config_path, 'x') as f:
    f.write('[defaults]\n')
    f.write('inventory = inventory\n')
    f.write('remote_user = {remote_user}\n')
    f.write('private_key_file = {private_key}\n')