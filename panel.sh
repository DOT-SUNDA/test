#!/bin/bash

# Pastikan script dijalankan dengan hak akses sudo
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit
fi

# Update dan upgrade sistem
echo "Updating and upgrading system..."
apt update -y && apt upgrade -y

# Install python3-venv jika belum ada
echo "Installing python3-venv..."
apt install -y python3-venv

# Membuat direktori untuk proyek
echo "Creating project directory..."
mkdir -p ~/flask-api
cd ~/flask-api

# Membuat virtual environment
echo "Creating virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install Flask
echo "Installing Flask..."
pip install Flask

# Membuat direktori untuk template
echo "Creating templates directory..."
mkdir templates

# Membuat file app.py
echo "Creating app.py file..."
cat > app.py << 'EOF'
from flask import Flask, render_template, request, redirect, url_for
import subprocess

app = Flask(__name__)

# Contoh email dan password yang valid
VALID_EMAIL = "user@example.com"
VALID_PASSWORD = "password123"

@app.route('/')
def index():
    return render_template('login.html')

@app.route('/login', methods=['POST'])
def login():
    email = request.form.get('email')
    password = request.form.get('password')

    # Verifikasi email dan password
    if email == VALID_EMAIL and password == VALID_PASSWORD:
        return redirect(url_for('run_bash'))
    else:
        return "Invalid credentials, please try again", 401

@app.route('/run-bash', methods=['GET', 'POST'])
def run_bash():
    if request.method == 'POST':
        # Dapatkan argument dari form
        arg = request.form.get('argument')

        try:
            # Menjalankan script bash dengan argument
            result = subprocess.run(['/bin/bash', 'script.sh', arg], capture_output=True, text=True)
            if result.returncode == 0:
                # Menampilkan output bash di halaman
                return render_template('bash_form.html', output=result.stdout)
            else:
                return render_template('bash_form.html', output="Error: " + result.stderr)
        except Exception as e:
            return render_template('bash_form.html', output="Error: " + str(e))

    return render_template('bash_form.html')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
EOF

# Membuat file login.html
echo "Creating login.html file..."
cat > templates/login.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
</head>
<body>
    <h2>Login</h2>
    <form action="{{ url_for('login') }}" method="post">
        <label for="email">Email:</label><br>
        <input type="email" id="email" name="email" required><br><br>
        
        <label for="password">Password:</label><br>
        <input type="password" id="password" name="password" required><br><br>
        
        <button type="submit">Login</button>
    </form>
</body>
</html>
EOF

# Membuat file bash_form.html
echo "Creating bash_form.html file..."
cat > templates/bash_form.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Run Bash Script</title>
</head>
<body>
    <h2>Enter Argument for Bash Script</h2>
    <form action="{{ url_for('run_bash') }}" method="post">
        <label for="argument">Argument:</label><br>
        <input type="text" id="argument" name="argument" required><br><br>
        
        <button type="submit">Run Script</button>
    </form>

    {% if output %}
    <h3>Output:</h3>
    <pre>{{ output }}</pre>
    {% endif %}
</body>
</html>
EOF

# Membuat script.sh
echo "Creating script.sh file..."
cat > script.sh << 'EOF'
#!/bin/bash
echo "Bash script running with argument: $1"
EOF

# Berikan izin eksekusi untuk script.sh
chmod +x script.sh

# Informasi untuk mengganti path script.sh
echo "Reminder: Please replace 'script.sh' in app.py with the actual path to your Bash script."

# Menyelesaikan instalasi dan setup
echo "Setup complete! To run the Flask app, activate the virtual environment and start the server with:"
echo "source venv/bin/activate"
echo "python app.py"
