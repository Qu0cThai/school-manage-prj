<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>School Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" crossorigin="anonymous">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" crossorigin="anonymous">
    <style>
        body {
            background: linear-gradient(135deg, #f0f4f8, #d9e2ec);
            font-family: 'Arial', sans-serif;
        }
        .navbar {
            background: linear-gradient(90deg, #4facfe, #00f2fe);
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            padding: 1rem 2rem;
        }
        .navbar-brand {
            color: white;
            font-weight: bold;
            transition: all 0.3s ease;
        }
        .navbar-brand:hover {
            color: #feb47b;
            transform: scale(1.05);
        }
        .navbar-nav .nav-link {
            color: white;
            margin-right: 1rem;
            transition: all 0.3s ease;
        }
        .navbar-nav .nav-link:hover {
            color: #feb47b;
            transform: scale(1.05);
        }
        .nav-item.active .nav-link {
            color: #feb47b;
            font-weight: bold;
        }
        .dropdown-menu {
            background: #ffffff;
            border: none;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
        }
        .dropdown-item {
            color: #4facfe;
            transition: all 0.3s ease;
        }
        .dropdown-item:hover {
            background: linear-gradient(90deg, #4facfe, #00f2fe);
            color: white;
        }
        .navbar-toggler-icon {
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 30 30'%3E%3Cpath stroke='rgba(255, 255, 255, 1)' stroke-width='2' stroke-linecap='round' stroke-miterlimit='10' d='M4 7h22M4 15h22M4 23h22'/%3E%3C/svg%3E");
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg">
        <div class="container">
            <a class="navbar-brand" href="index.jsp"><i class="fas fa-school me-2"></i>School Management</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarSupportedContent">
                <ul class="navbar-nav">
                    <li class="nav-item <%= request.getRequestURI().endsWith("index.jsp") ? "active" : "" %>">
                        <a class="nav-link" href="index.jsp"><i class="fas fa-home me-1"></i>Home <span class="visually-hidden">(current)</span></a>
                    </li>
                    <li class="nav-item <%= request.getRequestURI().endsWith("aboutus.jsp") ? "active" : "" %>">
                        <a class="nav-link" href="aboutus.jsp"><i class="fas fa-info-circle me-1"></i>About Us</a>
                    </li>
                </ul>
                <ul class="navbar-nav ms-auto">
                    <%
                        String username = (String) session.getAttribute("username");
                        if (username != null) {
                    %>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="fas fa-user-circle me-1"></i>Welcome, <%= username %>
                        </a>
                        <div class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
                            <a class="dropdown-item" href="logout.jsp"><i class="fas fa-sign-out-alt Mifflin: 0x1c4d2b1b6c0>]alt me-2"></i>Logout</a>
                        </div>
                    </li>
                    <%
                        } else {
                    %>
                    <li class="nav-item">
                        <a class="nav-link" href="login.jsp"><i class="fas fa-sign-in-alt me-1"></i>Login</a>
                    </li>
                    <%
                        }
                    %>
                </ul>
            </div>
        </div>
    </nav>