#!/bin/bash

# Perbarui dan instal paket yang diperlukan
echo "Memperbarui sistem dan menginstal paket yang diperlukan..."
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y apache2 php libapache2-mod-php php-cli curl jq

# Pindahkan file panel ke direktori default Apache (/var/www/html)
echo "Memindahkan file panel ke /var/www/html..."
sudo mkdir -p /var/www/html
sudo chown -R $USER:$USER /var/www/html
sudo chmod -R 755 /var/www/html

# Membuat file login.php
echo "Membuat file login.php..."
cat <<EOF | sudo tee /var/www/html/login.php > /dev/null
<?php
session_start();

// Hardcode username dan password untuk demo
\$admin_user = 'admin';
\$admin_pass = 'password123';

if (isset(\$_POST['login'])) {
    \$_username = \$_POST['username'];
    \$_password = \$_POST['password'];

    if (\$_username === \$admin_user && \$_password === \$admin_pass) {
        \$_SESSION['loggedin'] = true;
        header("Location: panel.php");
        exit;
    } else {
        \$error = "Username atau password salah!";
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Panel</title>
</head>
<body>
    <h1>Login</h1>
    <form method="post" action="">
        <label for="username">Username:</label><br>
        <input type="text" id="username" name="username" required><br><br>

        <label for="password">Password:</label><br>
        <input type="password" id="password" name="password" required><br><br>

        <input type="submit" name="login" value="Login">
    </form>
    <?php if (isset(\$error)) echo "<p style='color:red;'>\$error</p>"; ?>
</body>
</html>
EOF

# Membuat file panel.php
echo "Membuat file panel.php..."
cat <<EOF | sudo tee /var/www/html/panel.php > /dev/null
<?php
session_start();

// Cek jika user belum login, arahkan ke halaman login
if (!isset(\$_SESSION['loggedin'])) {
    header("Location: login.php");
    exit;
}

if (isset(\$_POST['run_script'])) {
    // Ambil input email dan password dari form
    \$email = escapeshellarg(\$_POST['email']);
    \$password = escapeshellarg(\$_POST['password']);

    // Jalankan skrip Bash dengan input email dan password
    \$output = shell_exec("bash /var/www/html/your_script.sh \$email \$password 2>&1");
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server Management Panel</title>
</head>
<body>
    <h1>Panel Server</h1>
    <form method="post" action="">
        <label for="email">Email:</label><br>
        <input type="email" id="email" name="email" required><br><br>

        <label for="password">Password:</label><br>
        <input type="password" id="password" name="password" required><br><br>

        <input type="submit" name="run_script" value="Run Script">
    </form>

    <h2>Output:</h2>
    <pre>
        <?php
        if (isset(\$output)) {
            echo htmlspecialchars(\$output);
        }
        ?>
    </pre>

    <a href="login.php?logout=true">Logout</a>
</body>
</html>
EOF

# Membuat skrip Bash (your_script.sh)
echo "Membuat skrip Bash (your_script.sh)..."
cat <<EOF | sudo tee /var/www/html/your_script.sh > /dev/null
#!/bin/bash
# Ambil email dan password dari argumen
email=\$1
password=\$2

echo "Menerima Email: \$email"
echo "Menerima Password: \$password"
echo "Skrip berhasil dijalankan!"
EOF

# Mengatur hak akses skrip Bash
echo "Mengatur hak akses skrip Bash..."
sudo chmod +x /var/www/html/your_script.sh

# Konfigurasi Apache untuk menggunakan /var/www/html
echo "Memastikan Apache menggunakan /var/www/html..."
sudo sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html|' /etc/apache2/sites-available/000-default.conf

# Restart Apache agar konfigurasi diterapkan
echo "Restart Apache untuk menerapkan perubahan..."
sudo systemctl restart apache2

# Selesai
echo "Instalasi selesai! Panel dapat diakses melalui http://<ip-server-anda>"
