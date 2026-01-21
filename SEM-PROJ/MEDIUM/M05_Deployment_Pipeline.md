# M05: Deployment Pipeline

> **Nivel:** MEDIUM | **Timp estimat:** 25-35 ore | **Bonus K8s:** +10%

## Descriere
Pipeline de deployment automat: build, test, deploy cu rollback și environments multiple (dev, staging, prod).

## Cerințe Obligatorii
1. **Build stage** - compilare/packaging aplicație
2. **Test stage** - rulare teste automate
3. **Deploy stage** - deployment pe environment specificat
4. **Rollback** - revenire la versiune anterioară
5. **Environments** - configurare per mediu (dev/staging/prod)
6. **Hooks** - pre-deploy, post-deploy scripts
7. **Locking** - prevenire deployments simultane
8. **Logging** - jurnal complet deployment

## Opționale
9. **Blue-green deployment**
10. **Canary releases**
11. **Approval gates** - aprobare manuală pentru prod

## Utilizare
```bash
./deploy.sh build
./deploy.sh test
./deploy.sh deploy staging
./deploy.sh deploy prod --approve
./deploy.sh rollback prod
```

*Proiect MEDIUM | Sisteme de Operare | ASE-CSIE*
