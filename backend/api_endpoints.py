# bat_track_v1/api_endpoints.py

from flask import Flask, jsonify, request
from flask_cors import CORS
from adapters.technicien_adapter import TechnicienAdapter
# ... autres imports

app = Flask(__name__)

# CORS différencié selon endpoint
CORS(app, resources={
    r"/api/public/*": {"origins": ["https://votre-emap.github.io", "http://localhost:*"]},
    r"/api/private/*": {"origins": ["https://bat-track-app.com"]}  # Seulement Bat_Track_V1
})

adapter = TechnicienAdapter()

# ============================================
# ENDPOINTS PUBLICS (pour EMAP)
# ============================================

@app.route('/api/public/v1/techniciens', methods=['GET'])
def rechercher_techniciens_public():
    """
    API publique pour EMAP
    Retourne TechnicienPublic (sans données sensibles)
    """

    specialite = request.args.get('specialite', '').lower()
    region = request.args.get('region')
    note_minimale = float(request.args.get('note_minimale', 3.0))

    criteres = CritereSelectionArtisan(
        specialite=map_specialite(specialite),
        code_postal=region,
        note_minimale=note_minimale,
        disponible_uniquement=True  # Toujours true pour public
    )

    artisans = sheets_manager.rechercher_artisans(criteres)

    # Conversion en format PUBLIC
    techniciens = [
        adapter.artisan_to_technicien_public_json(a)
        for a in artisans
        if a.actif  # Seulement les actifs
    ]

    return jsonify({
        'success': True,
        'count': len(techniciens),
        'data': techniciens
    })

@app.route('/api/public/v1/techniciens/<technicien_id>', methods=['GET'])
def obtenir_technicien_public(technicien_id):
    """Détails publics d'un technicien"""

    artisan = artisan_service.obtenir_artisan(technicien_id)

    if not artisan or not artisan.actif:
        return jsonify({'success': False, 'error': 'Non trouvé'}), 404

    technicien = adapter.artisan_to_technicien_public_json(artisan)

    return jsonify({
        'success': True,
        'data': technicien
    })

# ============================================
# ENDPOINTS PRIVÉS (pour Bat_Track_V1)
# ============================================

@app.route('/api/private/v1/techniciens', methods=['GET'])
def rechercher_techniciens_private():
    """
    API privée pour Bat_Track_V1
    Retourne Technicien complet (avec tous les champs)
    Nécessite authentification
    """

    # TODO: Vérifier token d'authentification

    # Paramètres de recherche plus étendus
    specialite = request.args.get('specialite', '').lower()
    region = request.args.get('region')
    disponible = request.args.get('disponible', 'true').lower() == 'true'

    criteres = CritereSelectionArtisan(
        specialite=map_specialite(specialite),
        code_postal=region,
        disponible_uniquement=disponible
    )

    artisans = sheets_manager.rechercher_artisans(criteres)

    # Conversion en format PRIVÉ (complet)
    techniciens = [
        adapter.artisan_to_technicien_private_json(a)
        for a in artisans
    ]

    return jsonify({
        'success': True,
        'count': len(techniciens),
        'data': techniciens
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)
