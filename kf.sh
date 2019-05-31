#####################################
# VARIABLE DEFINITION
#####################################
SYSTEM="MAC"
#SYSTEM="LINUX"
export KFAPP=test

#####################################
# REMOVE OLD ARTIFCATS
#####################################
rm kfctl.tar.gz
rm kfctl
rm -r ${KFAPP}
rm kubectl
rm ks.tar.gz
rm ks
rm -r $(find . -maxdepth 1 -mindepth 1 -type d)
rm install.log

#####################################
# DOWNLOAD KUBECTL
#####################################
if SYSTEM="MAC"
then
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl
else
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
fi

chmod +x ./kubectl

#####################################
# DOWNLOAD KUBEFLOW
#####################################
if SYSTEM="MAC"
then
curl -L https://github.com/kubeflow/kubeflow/releases/download/v0.5.1/kfctl_v0.5.1_darwin.tar.gz > kfctl.tar.gz
else
curl -L lttps://github.com/kubeflow/kubeflow/releases/download/v0.5.1/kfctl_v0.5.1_linux.tar.giz > kfctl.tar.gz
fi

tar xf kfctl.tar.gz
rm kfctl.tar.gz

#####################################
# DOWNLOAD KS
#####################################
if SYSTEM="MAC"
then
curl -L https://github.com/ksonnet/ksonnet/releases/download/v0.13.1/ks_0.13.1_darwin_amd64.tar.gz > ks.tar.gz
else
curl -L https://github.com/ksonnet/ksonnet/releases/download/v0.13.1/ks_0.13.1_linux_amd64.tar.gz > ks.tar.gz
fi

tar xf ks.tar.gz
rm ks.tar.gz
mv $(find . -maxdepth 1 -mindepth 1 -type d)/ks ./ks
rm -r $(find . -maxdepth 1 -mindepth 1 -type d)

#####################################
# PATH CONFIGURATION
#####################################
export PATH=$PWD
export KUBECONFIG=$PWD/kubeconfig.yaml

#####################################
# PRE-SETUP CHECKS
#####################################
kubectl version > ../install.log
ks version > ../install.log

#####################################
# KUBEFLOW SETUP
#####################################
kfctl init ${KFAPP}
cd ${KFAPP}
kfctl generate all
kfctl apply all

#####################################
# POST INSTALL
#####################################
kfctl show all > install.log
kubectl -n kubeflow get  all > install.log
