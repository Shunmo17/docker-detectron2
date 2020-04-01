##############################################################################
##                                 Base Image                               ##
##############################################################################
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

##############################################################################
##                                  Detectron                               ##
##############################################################################
# # ref https://github.com/DavidFernandezChaves/Detectron2_ros
# # Python v3.7 (in virtual environment)
# RUN apt-get update && apt-get install -y \
#     python3.7 \
#     python3-virtualenv
# RUN apt-get update && apt-get install -y python-pip
# RUN pip install --upgrade pip
# RUN pip install virtualenv
# RUN mkdir ~/.virtualenvs
# RUN pip install virtualenvwrapper
# RUN export WORKON_HOME=~/.virtualenvs
# RUN echo '. /usr/local/bin/virtualenvwrapper.sh' >> ~/.bashrc 

# # create virtual environment
# ## ref : https://github.com/NeuralEnsemble/pype9/blob/master/Dockerfile
# # RUN /bin/bash -c "source /usr/local/bin/virtualenvwrapper.sh; mkvirtualenv --python=python3 detectron2_ros"
# RUN /bin/bash -c "source /usr/local/bin/virtualenvwrapper.sh; python3.7 -m virtualenv --python=/usr/bin/python3 /opt/venv"
# RUN echo "============== Python version =============="
# RUN python3 --version
# RUN echo "============================================"
# # install git
# RUN apt-get update && apt-get install -y git

# # install dependencies
# RUN /opt/venv/bin/pip install -U torch==1.4+cu100 torchvision==0.5+cu100 -f https://download.pytorch.org/whl/torch_stable.html
# RUN /opt/venv/bin/pip install --ignore-installed cython pyyaml==5.1
# RUN /opt/venv/bin/pip install -U 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI'

# RUN python --version

# RUN /opt/venv/bin/pip install detectron2 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cu100/index.html
# RUN /opt/venv/bin/pip install opencv-python
# RUN /opt/venv/bin/pip install rospkg

##############################################################################
##                              bashrc setting                              ##
##############################################################################
# terminal text
RUN echo "export PS1='\[\e[1;31;40m\]DETECTRON2\[\e[0m\] \u:\w\$ '">> ~/.bashrc