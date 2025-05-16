<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="header.jsp"%>
    <body>
        <div class="container" style="min-height: 100vh; padding-bottom: 4rem;">
            <div class="row">
                <div class="col-12 col-sm-12 col-md-12">
                    <div class="row">
                        <div class="col-12">
                            <div class="container">
                                <br/>
                                <h3>All Students:</h3>
                                <div class="table-responsive">
                                    <table class="table table-striped">
                                        <thead class="thead-dark">
                                            <tr>
                                                <th scope="col">Student Name</th>
                                                <th scope="col">Roll No</th>
                                                <th scope="col">Mobile No</th>
                                                <th scope="col">Address</th>
                                                <th></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td scope="row">John Doe</td>
                                                <td>001</td>
                                                <td>123-456-7890</td>
                                                <td>123 Main St, City</td>
                                                <td>
                                                    <button type="button" class="btn">
                                                        <a href="studentDetail.jsp?s_id=S001">Details</a>
                                                    </button>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td scope="row">Jane Roe</td>
                                                <td>002</td>
                                                <td>987-654-3210</td>
                                                <td>456 Elm St, Town</td>
                                                <td>
                                                    <button type="button" class="btn">
                                                        <a href="studentDetail.jsp?s_id=S002">Details</a>
                                                    </button>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body>
<%@ include file="footer.jsp"%>