# Use the official Jupyter Docker image as the base image
FROM jupyter/base-notebook:latest

# Set the working directory
WORKDIR /home/jovyan

# Install necessary packages
RUN pip install notebook==6.* && \
    pip install pandas && \
    pip install scikit-learn && \
    pip install matplotlib && \
    pip install seaborn && \
    pip install nltk && \
    pip install beautifulsoup4

# Copy the Bash script and generate_hash.py into the container's working directory
COPY start-jupyter.sh /home/jovyan/start-jupyter.sh
COPY generate_hash.py /home/jovyan/generate_hash.py

# Accept UID and GID as build arguments
ARG USER_UID=1000
ARG USER_GID=100
ARG JUPYTER_PASSWORD

# Update jovyan user with the provided UID and GID
USER root
RUN usermod -u $USER_UID jovyan && \
    groupmod -g $USER_GID users && \
    chown -R jovyan:users /home/jovyan

# Make the Bash script executable
RUN chmod +x /home/jovyan/start-jupyter.sh

# Set the Jupyter password environment variable
ENV JUPYTER_PASSWORD=$JUPYTER_PASSWORD

# Run generate_hash.py to create the password hash
RUN python /home/jovyan/generate_hash.py > /home/jovyan/password_hash.txt

# Read the generated password hash and create the Jupyter configuration file
RUN echo "c.NotebookApp.password = '$(cat /home/jovyan/password_hash.txt)'" > /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.open_browser = False" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.allow_root = True" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.ip = '*'" >> /home/jovyan/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.port = 8888" >> /home/jovyan/.jupyter/jupyter_notebook_config.py

# Create soft links for Python and Jupyter
RUN ln -s /opt/conda/bin/python /usr/local/bin/python && \
    ln -s /opt/conda/bin/jupyter /usr/local/bin/jupyter

# Switch to the jovyan user
USER jovyan

# Expose the Jupyter Notebook port
EXPOSE 8888

# Start Jupyter Notebook server using the Bash script
CMD ["/bin/bash", "/home/jovyan/start-jupyter.sh"]
