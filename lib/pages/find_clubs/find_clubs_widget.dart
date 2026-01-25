import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/services/database_service.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'find_clubs_model.dart';
export 'find_clubs_model.dart';

class FindClubsWidget extends StatefulWidget {
  const FindClubsWidget({super.key});

  static String routeName = 'FindClubs';
  static String routePath = '/findClubs';

  @override
  State<FindClubsWidget> createState() => _FindClubsWidgetState();
}

class _FindClubsWidgetState extends State<FindClubsWidget> {
  late FindClubsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<ClubsRow> _clubs = [];
  List<ClubsRow> _filteredClubs = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedDiscipline;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FindClubsModel());
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    setState(() => _isLoading = true);

    try {
      final clubs = await databaseService.getAllClubs();
      if (mounted) {
        setState(() {
          _clubs = clubs;
          _filteredClubs = clubs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading clubs: ${e.toString()}'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    }
  }

  void _filterClubs() {
    setState(() {
      _filteredClubs = _clubs.where((club) {
        final matchesSearch = _searchQuery.isEmpty ||
            (club.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (club.location?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (club.discipline?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        final matchesDiscipline = _selectedDiscipline == null ||
            _selectedDiscipline!.isEmpty ||
            club.discipline == _selectedDiscipline;

        return matchesSearch && matchesDiscipline;
      }).toList();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 30.0,
            ),
            onPressed: () => context.pop(),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find Clubs',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      font: GoogleFonts.interTight(),
                      letterSpacing: 0.0,
                    ),
              ),
              Text(
                'Discover shooting clubs near you',
                style: FlutterFlowTheme.of(context).labelMedium.override(
                      font: GoogleFonts.inter(),
                      letterSpacing: 0.0,
                    ),
              ),
            ].divide(SizedBox(height: 4.0)),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 3.0,
                      color: Color(0x33000000),
                      offset: Offset(0.0, 1.0),
                    )
                  ],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.0),
                    bottomRight: Radius.circular(12.0),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Search Field
                      TextFormField(
                        controller: _searchController,
                        onChanged: (value) {
                          _searchQuery = value;
                          _filterClubs();
                        },
                        autofocus: false,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Search clubs...',
                          labelStyle: FlutterFlowTheme.of(context).labelMedium,
                          hintText: 'Search by name, location, or discipline',
                          hintStyle: FlutterFlowTheme.of(context).labelMedium,
                          prefixIcon: Icon(
                            Icons.search,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchQuery = '';
                                    _filterClubs();
                                  },
                                )
                              : null,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).alternate,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: FlutterFlowTheme.of(context).primaryBackground,
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                      SizedBox(height: 12.0),
                      // Discipline Filter Chips
                      FutureBuilder<List<DisciplinesRow>>(
                        future: DisciplinesTable().queryRows(
                          queryFn: (q) => q.order('discipline_name'),
                        ),
                        builder: (context, snapshot) {
                          final disciplines = snapshot.data ?? [];
                          final disciplineNames = disciplines
                              .map((d) => d.disciplineName)
                              .whereType<String>()
                              .toSet()
                              .toList();

                          if (disciplineNames.isEmpty) {
                            return SizedBox.shrink();
                          }

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                FilterChip(
                                  label: Text('All'),
                                  selected: _selectedDiscipline == null,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedDiscipline = null;
                                    });
                                    _filterClubs();
                                  },
                                  selectedColor: FlutterFlowTheme.of(context).primary,
                                  labelStyle: TextStyle(
                                    color: _selectedDiscipline == null
                                        ? Colors.white
                                        : FlutterFlowTheme.of(context).primaryText,
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                ...disciplineNames.map((discipline) => Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: FilterChip(
                                        label: Text(discipline),
                                        selected: _selectedDiscipline == discipline,
                                        onSelected: (selected) {
                                          setState(() {
                                            _selectedDiscipline = selected ? discipline : null;
                                          });
                                          _filterClubs();
                                        },
                                        selectedColor: FlutterFlowTheme.of(context).primary,
                                        labelStyle: TextStyle(
                                          color: _selectedDiscipline == discipline
                                              ? Colors.white
                                              : FlutterFlowTheme.of(context).primaryText,
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Results Count
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 8.0),
                child: Text(
                  '${_filteredClubs.length} clubs found',
                  style: FlutterFlowTheme.of(context).labelMedium.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        letterSpacing: 0.0,
                      ),
                ),
              ),

              // Clubs List
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      )
                    : _filteredClubs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64.0,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                ),
                                SizedBox(height: 16.0),
                                Text(
                                  'No clubs found',
                                  style: FlutterFlowTheme.of(context).headlineSmall,
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Try adjusting your search or filters',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(),
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadClubs,
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: _filteredClubs.length,
                              itemBuilder: (context, index) {
                                final club = _filteredClubs[index];
                                return _buildClubCard(club);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClubCard(ClubsRow club) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            ClubProfileWidget.routeName,
            queryParameters: {
              'clubId': serializeParam(club.id, ParamType.String),
            }.withoutNulls,
          );
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                blurRadius: 4.0,
                color: Color(0x1F000000),
                offset: Offset(0.0, 2.0),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Club Image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: club.coverImg != null && club.coverImg!.isNotEmpty
                    ? CachedNetworkImage(
                        fadeInDuration: Duration(milliseconds: 300),
                        fadeOutDuration: Duration(milliseconds: 300),
                        imageUrl: club.coverImg!,
                        width: double.infinity,
                        height: 120.0,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: FlutterFlowTheme.of(context).alternate,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: FlutterFlowTheme.of(context).alternate,
                          height: 120.0,
                          child: Icon(
                            Icons.gps_fixed,
                            size: 40.0,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: 120.0,
                        color: FlutterFlowTheme.of(context).alternate,
                        child: Icon(
                          Icons.gps_fixed,
                          size: 40.0,
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
              ),
              // Club Info
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            club.name ?? 'Unknown Club',
                            style: FlutterFlowTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                  letterSpacing: 0.0,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (club.isPrivate == true)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).alternate,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Text(
                              'Private',
                              style: FlutterFlowTheme.of(context).labelSmall,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    if (club.location != null && club.location!.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16.0,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                          SizedBox(width: 4.0),
                          Expanded(
                            child: Text(
                              club.location!,
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(),
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 4.0),
                    if (club.discipline != null && club.discipline!.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          club.discipline!,
                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                font: GoogleFonts.inter(),
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
