<?php
$host = getenv('POSTGRES_SERVICE_HOST') ?: 'db'; // Use the service name from Kubernetes
$db = getenv('POSTGRES_DB') ?: 'mydatabase';
$user = getenv('POSTGRES_USER') ?: 'user';
$password = getenv('POSTGRES_PASSWORD') ?: 'password';

// Ensure the port is an integer (handle cases where Kubernetes provides a full URL)
$port = parse_url(getenv('PPOSTGRES_PORT'), PHP_URL_PORT) ?: getenv('POSTGRES_SERVICE_PORT') ?: '5432';

try {
    // Connect to PostgreSQL
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
    <h3>Hello <?php echo getenv('NAME') ?: 'Mr.SK - You have achieved it'; ?>!</h3>
    <b>Hostname:</b> <?php echo gethostname(); ?><br/>
    <b>Visits:</b> <?php echo $visits; ?>
</body>
</html>
