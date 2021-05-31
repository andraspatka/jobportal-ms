#!/usr/bin/env bash
helm uninstall user-management-service
helm uninstall jobportal-service
helm uninstall event-management-service
helm uninstall posting-management-service
helm uninstall statistics-service

cd userManagementService
az acr build --image user-management-service:v1 --registry jobportal --file Dockerfile .
helm install user-management-service charts/
cd ..

cd jobsPortalService
az acr build --image jobportal-service:v2 --registry jobportal --file Dockerfile .
helm install jobportal-service charts/
cd ..

cd eventLoggingService
az acr build --image event-management-service:v1 --registry jobportal --file Dockerfile .
helm install event-management-service charts/
cd ..

cd postingsService
az acr build --image posting-management-service:v1 --registry jobportal --file Dockerfile .
helm install posting-management-service charts/
cd ..

cd statisticsService
az acr build --image statistics-service:v1 --registry jobportal --file Dockerfile .
helm install statistics-service charts/
cd ..
