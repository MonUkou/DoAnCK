<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Đăng nhập</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.2/css/bootstrap.min.css">

    <style>
        body {
            margin: 0;
            min-height: 100vh;
            background: linear-gradient(135deg, #eef2ff 0%, #cbd5e1 100%);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .card-login {
            border-radius: 1rem;
            box-shadow: 0 1rem 2rem rgba(0,0,0,0.1);
            max-width: 400px;
            width: 100%;
            padding: 2rem;
            background: #fff;
        }

        .form-group {
            margin-bottom: 1.2rem;
        }

        .btn-primary {
            width: 100%;
        }
    </style>
</head>

<body>

<div class="card-login">
    <h3 class="text-center mb-3">Đăng nhập</h3>

    <form method="post" action="index.php?controller=account&action=login">
        <div class="form-group">
            <label>Tên đăng nhập</label>
            <input type="text" name="username" class="form-control" required>
        </div>

        <div class="form-group">
            <label>Mật khẩu</label>
            <input type="password" name="password" class="form-control" required>
        </div>

        <button class="btn btn-primary">Đăng nhập</button>
    </form>
</div>

</body>
</html>
