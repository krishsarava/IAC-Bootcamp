<?php
$host = getenv('POSTGRES_HOST') ?: 'localhost';
$db = getenv('POSTGRES_DB') ?: 'mydatabase';
$user = getenv('POSTGRES_USER') ?: 'myuser';
$password = getenv('POSTGRES_PASSWORD') ?: 'mypassword';
$port = getenv('POSTGRES_PORT') ?: '5432';

// Connect to PostgreSQL
try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$db";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
} catch (PDOException $e) {
    die("<i>Cannot connect to PostgreSQL, error: " . $e->getMessage() . "</i>");
}

// Create table if not exists
$pdo->exec("CREATE TABLE IF NOT EXISTS visits (id SERIAL PRIMARY KEY, timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP);");
$pdo->exec("INSERT INTO visits DEFAULT VALUES;");

// Get visit count
$stmt = $pdo->query("SELECT COUNT(*) FROM visits;");
$visits = $stmt->fetchColumn();

?>
<!DOCTYPE html>
<html>
<head>
    <title>PHP & PostgreSQL</title>
</head>
<body>
    <h3>Hello <?php echo getenv('NAME') ?: 'world'; ?>!</h3>
    <b>Hostname:</b> <?php echo gethostname(); ?><br/>
    <b>Visits:</b> <?php echo $visits; ?>
</body>
</html>
