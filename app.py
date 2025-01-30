from flask import Flask, request, jsonify
from flask_cors import CORS
import subprocess
import os

app = Flask(__name__)

# Batasi domain asal dengan Flask-CORS
CORS(app, resources={r"/*": {"origins": ["https://vps.dot-aja.my.id", "http://localhost:5500"]}})

@app.route('/run-script', methods=['POST'])
def run_script():
    try:
        # Ambil email, password, dan script yang dipilih dari request
        data = request.get_json()
        email = data.get('email', '').strip()
        password = data.get('password', '').strip()
        script_name = data.get('script', '').strip()

        # Validasi input
        if not email or not password or not script_name:
            return jsonify({'status': 'error', 'message': 'Email, password, dan script harus diisi'}), 400
        
        # Periksa apakah script yang diminta ada dan berada di direktori yang diizinkan
        if not shutil.which(script_name):  # Cek jika script_name ada di PATH
            return jsonify({'status': 'error', 'message': 'Script {} tidak ditemukan atau tidak valid'.format(script_name)}), 400

        # Jalankan script dengan nama (tanpa path) sebagai argument
        result = subprocess.run(
            [script_name, email, password],  # Menjalankan script hanya dengan nama
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            shell=False  # Tidak menggunakan shell untuk keamanan
        )

        # Kembalikan hanya output dari script (stdout)
        return jsonify({
            'status': 'success',
            'output': result.stdout.strip()  # Hapus whitespace ekstra
        })
    except subprocess.CalledProcessError as e:
        return jsonify({'status': 'error', 'message': 'Script execution failed: {}'.format(e)}), 500
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
