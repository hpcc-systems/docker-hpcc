#!/usr/bin/python3
import sys
import getopt
import json
import os.path
from copyreg import constructor

class CollectIPs(object):
    def __init__(self):
        '''
        constructor
        '''
        self._out_dir =  "/tmp/hpcc_cluster"

    @property
    def out_dir(self):
        return self._out_dir

    @out_dir.setter
    def out_dir(self, value):
        self._out_dir = value

    def retrieveIPs(self, out_dir, input_fn):
        try:
            if out_dir:
                self._out_dir = out_dir
            if not os.path.exists(self._out_dir):
                os.makedirs(self._out_dir)

            if input_fn.lower().endswith('.json'):
                self.retrieveIPsFromJson(input_fn)
            else:
                print("Unsupport input file extension\n")
        except Exception as e:
            raise type(e)(str(e) +
                      ' Error in retrive IPs').with_traceback(sys.exc_info()[2])

    def retrieveIPsFromJson(self, input_fn):
        pass

    def clean_dir(self, target_dir):
        for f in os.listdir(target_dir):
            f_path = os.path.join(target_dir, f)
            if os.path.isfile(f_path):
                os.unlink(f_path)

    def write_to_file(self, base_dir, comp_type, ip):
        file_name = os.path.join(base_dir, comp_type)
        if os.path.exists(file_name):
            f_ips  = open (file_name, 'a')
        else:
            f_ips  = open (file_name, 'w')
        f_ips.write(ip + "\n")
        f_ips.close()


class IPsFromDockerNetwork (CollectIPs):

    def retrieveIPsFromJson(self, input_fn):
        with open(input_fn) as json_file:
            network_data = json.load(json_file)
            #print("open json file")
            #print(repr(network_data))
        self.clean_dir(self._out_dir)

        #print(repr(network_data['Containers']))
        for key in network_data['Containers']:
            node_name = (network_data['Containers'][key]['Name']).split('_')[1].split('.')[0]
            if ( node_name.startswith('admin')     or
                 node_name.startswith('dali')      or
                 node_name.startswith('esp')       or
                 node_name.startswith('thor')      or
                 node_name.startswith('roxie')     or
                 node_name.startswith('eclcc')     or
                 node_name.startswith('scheduler') or
                 node_name.startswith('backup')    or
                 node_name.startswith('sasha')     or
                 node_name.startswith('dropzone')  or
                 node_name.startswith('support')   or
                 node_name.startswith('spark')     or
                 node_name.startswith('node')):
                print("node name: " + node_name)
                node_ip = (network_data['Containers'][key]['IPv4Address']).split('/')[0]
                print("node ip: " + node_ip)
                self.write_to_file(self._out_dir, node_name, node_ip + ";")

    def usage(self):
        print("Usage IPsFromDockerNetwork.py [option(s)]\n")
        print(" -d --ip-dir    output pod ip directory. The default is /tmp/ips.")
        print(" -i --in-file   input docker network file in json format.")
        print(" -h --help     print this usage help.")
        print("\n");


if __name__ == '__main__':
    cIps = IPsFromDockerNetwork()
    try:
        input_filname = ""
        opts, args = getopt.getopt(sys.argv[1:],":d:i:h",
            ["help", "ip-dir", "in-file"])

        for arg, value in opts:
            if arg in ("-?", "--help"):
                cIps.usage()
                exit(0)
            elif arg in ("-d", "--ip-dir"):
                cIps.out_dir = value
            elif arg in ("-i", "--in-file"):
                input_filename = value

        cIps.retrieveIPs("", input_filename)

    except getopt.GetoptError as err:
        print(str(err))
        cIps.usage()
        exit(0)

    except Exception as e:
        print(e)
        print("Use -h or--help to see the usage.\n");
