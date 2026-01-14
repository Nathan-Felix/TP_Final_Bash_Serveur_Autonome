#!/bin/bash

# Script de vérification système et redémarrage des services
# Nathan

echo "============================================"
echo "=== VÉRIFICATION SYSTÈME COMPLÈTE ==="
echo "============================================"
echo "Date : $(date)"
echo ""

# ==========================================
# 1. VÉRIFICATION DES RESSOURCES
# ==========================================

echo "=== 1. Vérification des ressources ==="
echo ""

# Définir les seuils
SEUIL_DISQUE=75
SEUIL_RAM=90

# Vérifier l'espace disque trouvé sur https://labex.io/
echo "--- Espace disque sur / ---"
df -h /
echo ""

# Extraire le pourcentage d'utilisation du disque
DISQUE=$(df / | grep / | awk '{print $5}' | tr -d '%')
echo "Utilisation du disque : $DISQUE%"

# Vérifier le seuil disque
if [ $DISQUE -ge $SEUIL_DISQUE ]; then
    echo "⚠️  WARNING : Seuil disque dépassé ($DISQUE% >= $SEUIL_DISQUE%)"
else
    echo "✓ OK : Espace disque suffisant"
fi
echo ""

# Vérifier la mémoire RAM
echo "--- Mémoire RAM ---"
free -h
echo ""

# Calculer le pourcentage de RAM utilisée trouvé sur https://unix.stackexchange.com/
TOTAL_RAM=$(free | grep Mem | awk '{print $2}')
USED_RAM=$(free | grep Mem | awk '{print $3}')
POURCENTAGE_RAM=$((USED_RAM * 100 / TOTAL_RAM))

echo "RAM utilisée : $POURCENTAGE_RAM%"

# Vérifier le seuil RAM
if [ $POURCENTAGE_RAM -ge $SEUIL_RAM ]; then
    echo "⚠️  WARNING : Seuil RAM dépassé ($POURCENTAGE_RAM% >= $SEUIL_RAM%)"
else
    echo "✓ OK : Mémoire RAM suffisante"
fi
echo ""

# Lister les 3 processus les plus consommateurs en CPU trouvé sur https://www.cyberciti.biz/faq/linux-find-top-cpu-consumers/
echo "--- Top 3 processus consommateurs en CPU ---"
ps aux --sort=-%cpu | head -n 4
echo ""

# Lister les 3 processus les plus consommateurs en RAM trouvé sur https://www.cyberciti.biz/faq/linux-check-memory-usage/
echo "--- Top 3 processus consommateurs en RAM ---"
ps aux --sort=-%mem | head -n 4
echo ""

echo "============================================"
echo ""

# ==========================================
# 2. REDÉMARRAGE CONDITIONNEL DES SERVICES
# ==========================================

echo "=== 2. Redémarrage conditionnel des services ==="
echo ""

# Définition du tableau des services critiques trouvé sur https://www.gnu.org/software/bash/manual/html_node/Arrays.html
services=("network-manager" "cron" "apache2")

# Compteur d'erreurs
erreurs=0

# Boucle for pour itérer sur le tableau de services trouvé sur https://linuxize.com/post/bash-for-loop/
for service in "${services[@]}"; do
    echo "Vérification du service : $service"
    
    # Vérification du statut avec systemctl is-active trouvé sur https://www.freedesktop.org/software/systemd/man/systemctl.html
    if systemctl is-active --quiet "$service"; then
        echo "  ✓ $service est actif"
    else
        echo "  ✗ $service est inactif - Tentative de redémarrage..."
        
        # Tentative de redémarrage UNE SEULE FOIS trouvé sur https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units
        if systemctl restart "$service" 2>/dev/null; then
            echo "  ✓ $service a été redémarré avec succès"
        else
            echo "  ✗ ERROR : Échec du redémarrage de $service"
            ((erreurs++))
        fi
    fi
    echo ""
done

# Résumé final
echo "============================================"
echo "=== RÉSUMÉ ==="
echo "============================================"
echo "Services vérifiés : ${#services[@]}"
echo "Erreurs de redémarrage : $erreurs"
echo ""

# Code de sortie basé sur les erreurs trouvé sur https://tldp.org/LDP/abs/html/exit-status.html
if [ $erreurs -gt 0 ]; then
    echo "⚠️  Attention : Des erreurs ont été détectées"
    exit 1
else
    echo "✓ Vérification terminée avec succès"
    exit 0
fi
