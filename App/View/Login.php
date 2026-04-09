<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Đăng nhập</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.2/css/bootstrap.min.css" integrity="sha512-+YbYYW1qAcKt7qxC7vf6PZpu9VJ3OftiBBztwzt7XJCiM57jzOd3XMiM6N84Iq0C9X5d3HgtJ5YuPW1M7YcXMQ==" crossorigin="anonymous" referrerpolicy="no-referrer" />
    <style>
        :root {
            --layout-offset: 0px;
        }
        body {
            margin: 0;
            min-height: 100vh;
            background: radial-gradient(circle at top left, rgba(255,255,255,0.18), transparent 20%),
                        linear-gradient(135deg, #eef2ff 0%, #cbd5e1 100%);
            color: #1f2937;
        }
        .login-wrapper {
            
            min-height: calc(100vh - var(--layout-offset));
            min-height: calc(100dvh - var(--layout-offset));
            padding: 24px 15px;
            box-sizing: border-box;
        }
        .card-login {
            border: 0;
            border-radius: 1.25rem;
            overflow: hidden;
            box-shadow: 0 1.5rem 2.5rem rgba(15, 23, 42, 0.14);
            max-width: 420px;
            margin: auto;
            padding: 1.25rem;
            margin-top: 5rem;
        }
        .login-card-body {
            padding: 2.75rem;
        }
        .brand-circle {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background: #4f46e5;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 1rem;
        }
        .login-title {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
        }
        .login-subtitle {
            color: #64748b;
            margin-bottom: 1.5rem;
        }
        .form-group {
            display: grid;
            grid-template-columns: 160px 1fr; /* 🔥 2 cột cố định */
            align-items: center;
            margin-bottom: 1.5rem;
            column-gap: 15px;
        }
        .form-group label {
            text-align: left;
            margin: 0;
            font-weight: 600;
            color: #475569;
            white-space: nowrap;
        }
        .form-control {
            width: 100%;
            border: none;
            border-bottom: 1px solid rgba(100, 116, 139, 0.3);
            padding: 10px 0;
            background: transparent;
        }
        .form-control:focus {
            border-bottom-color: #6366f1;
            background: transparent;
            box-shadow: none;
            outline: none;
            border-bottom: 2px solid #6366f1;
        }
        .form-control::placeholder {
            color: rgba(100, 116, 139, 0.6);
            font-weight: 400;
        }
        .btn-primary {
            border-radius: 1rem;
            padding: 12px 18px;
            font-weight: 600;
        }
        .login-submit {
            display: block;
            margin: 0 auto;
            width: auto;
            max-width: 200px;
        }
        .login-submit {
            display: block;
            width: fit-content;
            min-width: 180px;
            margin: 0 auto;
        }
        .divider {
            text-align: center;
            margin: 2rem 0 1.25rem;
            position: relative;
        }
        .divider span {
            background: #fff;
            padding: 0 1rem;
            color: #94a3b8;
            position: relative;
            z-index: 1;
        }
        .divider::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 0;
            right: 0;
            height: 1px;
            background: #e2e8f0;
            transform: translateY(-50%);
        }
        .text-secondary-light {
            color: #64748b;
        }
        @media (max-width: 576px) {
            .login-card-body {
                padding: 2rem;
            }
        }
    </style>
</head>
<body>
    <div class="container-fluid login-wrapper d-flex align-items-center justify-content-center">
        <div class="card card-login shadow-lg">
            <div class="card-body login-card-body bg-white">
                <div class="text-center mb-4">
                    <h1 class="login-title">Đăng nhập</h1>
                    <p class="login-subtitle">Nhập thông tin tài khoản để truy cập hệ thống.</p>
                </div>
                <form method="post" action="index.php?controller=account&action=login">
                    <div class="form-group">
                        <label for="username">Tên đăng nhập</label>
                        <input type="text" class="form-control" id="username" name="username" placeholder="Nhập tên đăng nhập" required>
                    </div>
                    <div class="form-group">
                        <label for="password">Mật khẩu</label>
                        <input type="password" class="form-control" id="password" name="password" placeholder="Nhập mật khẩu" required>
                    </div>
                    <button type="submit" class="btn btn-primary login-submit">Đăng nhập</button>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.4/jquery.slim.min.js" integrity="sha512-zH5StthoRxoP+vvOMvg3ar8fF8i+ocOq1G54bGfDhgnrsK2eKs+04dxps0p5xMzTYk1MnYx3LE5wBrE2jkT2NQ==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.2/js/bootstrap.bundle.min.js" integrity="sha512-XT+GUHkOs0JpdaV1V0JtF+mubMRhWwfPru1D1YCTFtDm2L1be7l08+//jtwAdb21LCAhS2yKFz2N8gkRE7r/jQ==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
</body>
</html>
