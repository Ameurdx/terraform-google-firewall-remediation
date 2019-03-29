import base64
import json
import googleapiclient.discovery

def process_log_entry(data, context):
    data_buffer = base64.b64decode(data['data'])
    log_entry = json.loads(data_buffer)

    firewall_name = log_entry['jsonPayload']['resource']['name']
    project_id = log_entry['resource']['labels']['project_id']

    service = create_service()

    print('Describing Firewall')

    get_source_ranges(project_id, service, firewall_name)
    get_allowed_ports(project_id, service, firewall_name)
    
    print(log_entry)
    print(firewall_name)
    print(project_id)

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

def get_allowed_ports(project_id, client, firewall):
    request = client.firewalls().get(project=project_id, firewall=firewall)
    response = request.execute()
    ports_list = []
    allowed_ports = response['allowed']

    for item in allowed_ports:
        ports = item['ports']
        print(ports)
        ports_list = ports_list.append(ports)

    print(ports_list)
    return allowed_ports
