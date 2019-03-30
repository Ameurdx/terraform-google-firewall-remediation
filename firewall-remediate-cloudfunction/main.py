import base64
import json
import googleapiclient.discovery
import string
import time

def process_log_entry(data, context):
    data_buffer = base64.b64decode(data['data'])
    log_entry = json.loads(data_buffer)

    firewall_name = log_entry['jsonPayload']['resource']['name']
    project_id = log_entry['resource']['labels']['project_id']

    service = create_service()
    print('Describing Firewall')
    disabled = check_for_disabled(project_id,service,firewall_name)
    source_ranges = get_source_ranges(project_id, service, firewall_name)
    allow_all = check_for_allowed_all(project_id, service, firewall_name)

    if allow_all == True:
        time.sleep(20)
        disable_firewall(project_id, service, firewall_name)
        print("Firewall %s Disabled" % firewall_name)
    else:
        allowed_ports = get_allowed_ports_list(project_id, service, firewall_name)
        ssh_allowed = check_for_port_22(allowed_ports)
        print(ssh_allowed)
        print(source_ranges)
        if ssh_allowed == True and '0.0.0.0/0' in source_ranges and disabled == False:
            time.sleep(20)
            disable_firewall(project_id, service, firewall_name)
            print("Firewall %s Disabled" % firewall_name)
        elif ssh_allowed == True and '0.0.0.0/0' in source_ranges and disabled == True:
            print("Firewall %s allows SSH from the Internet but is disabled")
        else:
            print('Firewall %s does not allow SSH inbound from the internet' % firewall_name)

def create_service():
    # Construct the service object for interacting with the Cloud Compute API -
    # the 'compute' service, at version 'v1'.
    # Authentication is provided by application default credentials.
    # When running locally, these are available after running
    # `gcloud auth application-default login`. When running on Compute
    # Engine, these are available from the environment.
    return googleapiclient.discovery.build('compute', 'v1')

def get_source_ranges(project_id, client, firewall):
    request = client.firewalls().get(project=project_id, firewall=firewall)
    response = request.execute()

    source_ranges = response['sourceRanges']
    print(source_ranges)
    return source_ranges

def get_allowed_ports_list(project_id, client, firewall):
    request = client.firewalls().get(project=project_id, firewall=firewall)
    response = request.execute()
    print(response)
    ports = []
    for each in response['allowed']:
        ports_list = each['ports']
        for port in ports_list:
            ports.append(port)
    print(ports)
    return ports

def check_for_allowed_all(project_id, client, firewall):
    request = client.firewalls().get(project=project_id, firewall=firewall)
    response = request.execute()
    print(response)
    for each in response['allowed']:
        if each['IPProtocol'] == 'all':
            return True
        else: 
            return False

def check_for_disabled(project_id, client, firewall):
    request = client.firewalls().get(project=project_id, firewall=firewall)
    response = request.execute()
    print(response)
    if response['disabled'] == True:
        return True
    else:
        return False


def check_for_port_22(ports):
    for item in ports:
        if '-' in item:
            start_num = item.split("-")[0]
            end_num = item.split("-")[1]

            if int(start_num) <= 22 <= int(end_num):
                return True
            else:
                return False
        elif item == '22':
            return True
        else:
            return False

def disable_firewall(project_id, client, firewall):
    firewall_body = {
    "name": firewall,
    "disabled": "true"
    }
    request = client.firewalls().patch(project=project_id, firewall=firewall, body=firewall_body)
    response = request.execute()