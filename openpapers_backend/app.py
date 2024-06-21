from flask import Flask, render_template, request, redirect, url_for, flash, send_from_directory
import os
from werkzeug.utils import secure_filename
import json

UPLOAD_FOLDER = './files'
ALLOWED_EXTENSIONS = {'*'}

app = Flask(__name__)
app.config['SECRET_KEY'] = 'myfuckingsecurekeyhehe'  # Change this to a secure secret key
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER


# relaxing security for more useability
from flask_cors import CORS
CORS(app, resources={r"/*": {"origins": "*"}}) # allows requests from all origins


@app.route('/', methods=['GET'])
@app.route('/<path:path>', methods=['GET'])
def get_directory_contents(path=''):
    directory_path = os.path.join(app.config['UPLOAD_FOLDER'], path)
    if os.path.isdir(directory_path):
        contents = os.listdir(directory_path)
        return json.dumps(contents)
    else:
        if '/' in path:
            directory, filename = directory_path.rsplit('/', 1)
            return send_from_directory(directory, filename, as_attachment=True)
        else:
            return send_from_directory(app.config['UPLOAD_FOLDER'], path, as_attachment=True)


@app.route('/', methods=['POST'])
@app.route('/<path:path>', methods=['POST'])
def upload_file(path=''):
    if 'file' not in request.files:
        return json.dumps({"error": "No file part in the request"}), 400

    file = request.files['file']
    if file.filename == '':
        return json.dumps({"error": "No selected file"}), 400

    if file:
        directory_path = os.path.join(app.config['UPLOAD_FOLDER'], path)
        if not os.path.exists(directory_path):
            os.makedirs(directory_path)
        filename = secure_filename(file.filename)
        file.save(os.path.join(directory_path, filename))
        return json.dumps({"success": f"File {filename} uploaded successfully to {directory_path}"}), 200

    return json.dumps({"error": "File type not allowed"}), 400


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=7860)
