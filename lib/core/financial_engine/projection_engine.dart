// Re-export de shared_models pour éviter le doublon de CashflowProjection/ProjectionEngine.
// Le fichier local était identique à shared_models/core/financial_engine/projection_engine.dart.
// ADR 004 : toute la logique métier est dans shared_models.
export 'package:shared_models/core/financial_engine/projection_engine.dart';
