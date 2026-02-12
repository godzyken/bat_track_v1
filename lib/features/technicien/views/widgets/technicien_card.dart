import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_models/shared_models.dart';

class TechnicienCard extends StatelessWidget {
  final Technicien technicien;
  final bool selected;
  final VoidCallback onTap;

  const TechnicienCard({
    super.key,
    required this.technicien,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? Colors.green.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.green : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Colors.black.withAlpha((255 * 0.05).toInt()),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: technicien.disponible
                  ? Colors.green
                  : Colors.grey,
              child: const Icon(Icons.person, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              technicien.nom,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            Text(
              technicien.specialite,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            if (technicien.localisation != null)
              Text(
                technicien.localisation!,
                style: const TextStyle(fontSize: 11, color: Colors.black45),
              ),
            const SizedBox(height: 6),
            if (technicien.rating != null)
              RatingBarIndicator(
                rating: double.tryParse(technicien.rating.toString()) ?? 0,
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                itemSize: 14,
              ),
          ],
        ),
      ),
    );
  }
}
