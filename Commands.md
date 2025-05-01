// on backend

```
sudo docker run -d \
  --name employee-backend \
  -p 8080:8080 \
  -e DB_HOST=172.17.0.1 \
  -e DB_USER=postgres \
  -e DB_PASSWORD=admin123 \
  -e DB_NAME=employeedb \
  -e DB_PORT=5432 \
  -e ALLOWED_ORIGINS=http://localhost:3000 \
  employee-backend

sudo docker container stop de65a027ae0d
sudo docker container rm de65a027ae0d

http://3.88.235.188:8080/employees
http://3.88.235.188:8080/

curl -X POST http://18.204.224.252:8080/employees   -H "Content-Type: application/json"   -d '{
    "employee_id": 101,
    "name": "Atul Kamble"
}'

curl http://18.204.224.252:8080/employees
```
