<?php
$host = getenv('POSTGRES_SERVICE_HOST') ?: 'db';
$db = getenv('POSTGRES_DB') ?: 'voting_db';
$user = getenv('POSTGRES_USER') ?: 'user';
$password = getenv('POSTGRES_PASSWORD') ?: 'password';
$port = getenv('POSTGRES_PORT') ?: '5432';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$db";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
} catch (PDOException $e) {
    die("Cannot connect to PostgreSQL: " . htmlspecialchars($e->getMessage()));
}

// Create table if not exists
$pdo->exec("CREATE TABLE IF NOT EXISTS votes (
    id SERIAL PRIMARY KEY,
    candidate VARCHAR(100) NOT NULL,
    voter_ip VARCHAR(45),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);");

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['candidate'])) {
    $candidate = $_POST['candidate'];
    $voter_ip = $_SERVER['REMOTE_ADDR'] ?? 'Unknown';
    
    // Store vote
    $stmt = $pdo->prepare("INSERT INTO votes (candidate, voter_ip) VALUES (:candidate, :voter_ip)");
    $stmt->execute(['candidate' => $candidate, 'voter_ip' => $voter_ip]);
    
    echo "<p style='font-size: 20px; color: green; text-align: center;'>Vote recorded successfully!</p>";
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Best Team</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
        }
        h2 {
            font-size: 28px;
        }
        label {
            font-size: 24px;
            display: block;
            margin: 10px 0;
        }
        button {
            font-size: 24px;
            padding: 10px 20px;
            margin-top: 20px;
            background-color: #007bff;
            color: white;
            border: none;
            cursor: pointer;
            border-radius: 5px;
        }
        button:hover {
            background-color: #0056b3;
        }
        .link {
            font-size: 22px;
            display: inline-block;
            margin-top: 20px;
            text-decoration: none;
            color: #007bff;
        }
        .link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <h2>Vote for Your Favorite Team</h2>
    <form method="post">
        <label>
            <input type="radio" name="candidate" value="Team 1" required> Team 1
        </label>
        <label>
            <input type="radio" name="candidate" value="Team 2" required> Team 2
        </label>
        <label>
            <input type="radio" name="candidate" value="Team 3" required> Team 3
        </label>
        <label>
            <input type="radio" name="candidate" value="Team 4" required> Team 4
        </label>
        <button type="submit">Submit Vote</button>
    </form>
    <br>
    <a href="results.php" class="link">View Results</a>
</body>
</html>
