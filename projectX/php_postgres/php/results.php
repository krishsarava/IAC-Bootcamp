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

// Fetch voting results
$query = "SELECT candidate, COUNT(*) as votes FROM votes GROUP BY candidate ORDER BY votes DESC";
$stmt = $pdo->query($query);
$results = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html>
<head>
    <title>Voting Results</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
        }
        h2 {
            font-size: 24px;
        }
        table {
            margin: 0 auto;
            border-collapse: collapse;
            width: 50%;
        }
        th, td {
            border: 1px solid black;
            padding: 10px;
            font-size: 20px;
        }
        .vote-button {
            font-size: 24px;
            padding: 10px 20px;
            margin: 10px;
            display: inline-block;
            background-color: #007bff;
            color: white;
            border: none;
            cursor: pointer;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <h2>Best Team of IAC</h2>
    <table>
        <tr>
            <th>Team</th>
            <th>Votes</th>
        </tr>
        <?php foreach ($results as $row): ?>
            <tr>
                <td><strong><?= htmlspecialchars($row['candidate']) ?></strong></td>
                <td><?= $row['votes'] ?></td>
            </tr>
        <?php endforeach; ?>
    </table>
    <br>
    <a href="index.php" class="vote-button">Back to Voting</a>
</body>
</html>
