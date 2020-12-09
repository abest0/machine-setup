Machine Setup
========

This repo contains an [Ansible](https://www.ansible.com/) [playbook](https://www.tutorialspoint.com/ansible/ansible_playbooks.htm) to configure a cloud machine as a development machine.

## Overview

Setting up a cloud machine for development should be easy. However, it is often a struggle. Typically, you SSH into a box and start the process. Maybe you have a collection of scripts to bootstrap the process. If not, piece by piece, you install the components you use most often and over time install and configure the tools you need to actually get your job done. Do you dare do it again? What happens when you need a machine with different hardware? Is there a better way? A perfectly standard set of answers to these questions is No, cry, Yes?

*Yes?* Yes. Using this playbook as a base, you can build a new development machine, tailored to your needs, for each project you work on...in minutes. Why? Beacuse you should not be limited by the hardware limitations on the machine where you sit.

## Getting Started

### Prerequisites
The following prerequisites should be all you need to get started:

- Clone this repository to your local machine

- Install [pipenv](https://pypi.org/project/pipenv/)

- Install [pyenv](https://github.com/pyenv/pyenv#installation)


### Local Environment Setup

1. Running pipenv install will build the python virtualenv with all the dependencies necessary to configure a machine with ansible.

    ```
    # initialize the pipenv virtual environment and install all required packages
    pipenv install
    ```

***NOTE: Executing this command is only necessary the first time you are executing a playbook from a host machine.***
1. The ansible playbook builds upon a number of [roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html). Executing the following `pipenv` script calls `ansible-galaxy` command to install these dependencies.

    ```
    # install all dependent roles from ansible galaxy
    pipenv run galaxy-install
    ```

### Cloud Resources

While this configuraiton of cloud resources could be used for any machine accessible over SSH, I'll focus on AWS cloud resources for this demo.

1. Follow the instructions for creating an [Amazon EC2 Linux Instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html)

    1. For the AMI, select an Amazon Linux 2 AMI and Launch the Instance

    1. Once the cloud resources are created, ensure that you can SSH to the machine

    ```
    ❯ ssh <USER>@<MACHINE_LOCATION>


    # e.g. if using IP address
    ❯ ssh ec2-user@192.168.0.1


    # e.g. if using AWS instance-id to connect
    ❯ ssh ec2-user@i-123456789012345
    ```

### Provisioning the Development Machine

1. Use the provided ansible playbook to provision the machine. ***NOTE: 1) depending on the cloud OS and distribution you are using, the default username (specified by -u) may differ

    ```
    # run an ansible playbook against the development environment
    ❯ pipenv run setup <INSTANCE IP ADDRESS or URI> <name of default user if not ec2-user>
    ```


This process will take some time, but you'll see the following output:

    ❯ pipenv run setup 192.168.55.22

    PLAY [all] ****************************************************************************

    TASK [Gathering Facts] ****************************************************************
    ok: [192.168.55.22]

    ...

    TASK [Copy install-tmux script] *******************************************************
    changed: [i-0f5b2a93aa75755cd]

    PLAY RECAP ****************************************************************************
    i-0f5b2a93aa75755cd        : ok=50   changed=35   unreachable=0    failed=0    skipped=18   rescued=0    ignored=0


## Wrap Up
Congratulations, you have now provisioned a cloud machine as a development environment! SSH into the machine and begin developing with vim or connect to it with Visual Studio Code.
