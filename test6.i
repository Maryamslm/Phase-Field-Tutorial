# Authored for Mediloy S-Co (Co-Cr-W) Phase-Field Simulation
# Simulates phase fraction evolution of FCC (eta1), HCP (eta2), and mu-phase (eta3)
# 3-Phase KKS Model with Anisotropic Elasticity (No Carbides)
##########################################################################################################################################################################

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 40
  ny = 40
  nz = 0
  xmin = 0
  xmax = 400  # nm
  ymin = 0
  ymax = 400  # nm
  zmin = 0
  zmax = 0
  elem_type = QUAD4
[]

#########################################################################################
[BCs]
  [./Periodic]
    [./all]
      auto_direction = 'x y'
    [../]
  [../]
  
  # Zero displacement BCs for elasticity
  [./right_x]
    type = DirichletBC
    variable = disp_x
    boundary = right
    value = 0
  [../]
  [./left_x]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0
  [../]
  [./top_y]
    type = DirichletBC
    variable = disp_y
    boundary = top
    value = 0
  [../]
  [./bottom_y]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0
  [../]
[]

#########################################################################################
[AuxVariables]
  [./bnds]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./Energy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./gr_ca]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./gr_cb]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./von_mises]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./sigma11]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./sigma22]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./sigma12]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

#########################################################################################
[Variables]
  # Chemical potential variables (global)
  [./wa] 
    order = FIRST
    family = LAGRANGE
    scaling = 1.0E6
  [../]
  [./wb] 
    order = FIRST
    family = LAGRANGE
    scaling = 1.0E6
  [../]

  # Global composition variables (ca = Co, cb = Cr; W is implicitly 1 - ca - cb)
  [./ca]
    order = FIRST
    family = LAGRANGE
  [../]
  [./cb]
    order = FIRST
    family = LAGRANGE
  [../]

  # Phase-specific compositions
  [./c1a] # FCC Co
    order = FIRST
    family = LAGRANGE
  [../]
  [./c2a] # HCP Co
    order = FIRST
    family = LAGRANGE
  [../]
  [./c3a] # mu-phase Co
    order = FIRST
    family = LAGRANGE
  [../]

  [./c1b] # FCC Cr
    order = FIRST
    family = LAGRANGE
  [../]
  [./c2b] # HCP Cr
    order = FIRST
    family = LAGRANGE
  [../]
  [./c3b] # mu-phase Cr
    order = FIRST
    family = LAGRANGE
  [../]

  # Order parameters (1 per distinct phase)
  [./eta1] # FCC Matrix
    order = FIRST
    family = LAGRANGE
  [../]
  [./eta2] # HCP Precipitate
    order = FIRST
    family = LAGRANGE
  [../]
  [./eta3] # mu-phase Precipitate
    order = FIRST
    family = LAGRANGE
  [../]

  # Displacement variables for elasticity
  [./disp_x]
    scaling = 1.0E-05 
  [../]
  [./disp_y]
    scaling = 1.0E-05 
  [../]
[]

#########################################################################################
[ICs]
  # Supersaturated FCC matrix with small nuclei of HCP and mu-phase to trigger growth
  [./eta1]
    variable = eta1
    type = FunctionIC
    function = 'r2:=sqrt((x-200)^2+(y-200)^2); r3:=sqrt((x-300)^2+(y-300)^2); if(r2<=30,0,if(r3<=25,0,1))'
  [../]
  [./eta2] # HCP nucleus
    variable = eta2
    type = FunctionIC
    function = 'r2:=sqrt((x-200)^2+(y-200)^2); if(r2<=30,1,0)'
  [../]
  [./eta3] # mu-phase nucleus
    variable = eta3
    type = FunctionIC
    function = 'r3:=sqrt((x-300)^2+(y-300)^2); if(r3<=25,1,0)'
  [../]

  # Global composition ICs (ca = Co, cb = Cr)
  [./ca]
    variable = ca
    type = FunctionIC
    function = 'r2:=sqrt((x-200)^2+(y-200)^2); r3:=sqrt((x-300)^2+(y-300)^2); if(r2<=30,0.68,if(r3<=25,0.55,0.64))'
  [../]
  [./cb]
    variable = cb
    type = FunctionIC
    function = 'r2:=sqrt((x-200)^2+(y-200)^2); r3:=sqrt((x-300)^2+(y-300)^2); if(r2<=30,0.22,if(r3<=25,0.10,0.25))'
  [../]
[]

#########################################################################################
[Materials]
  # Scale factors for unit conversion (m to nm, J to eV, s to ns)
  [./scale]
    type = GenericConstantMaterial
    prop_names = 'length_scale energy_scale time_scale'
    prop_values = '1e9 6.24150943e18 1.0e9'
  [../]

  # Molar Volume (Calculated: 7.62e-6 m³/mol)
  [./molar_vol_mat]
    type = GenericConstantMaterial
    prop_names = 'molar_vol'
    prop_values = '7.62e-6'
  [../]

  # Model constants
  [./model_constants]
    type = GenericConstantMaterial
    prop_names = 'sigma delta gamma'
    prop_values = '0.50 35.0e-09 1.5' 
  [../]
  
  [./kappa_isotropy]
    type = ParsedMaterial
    f_name = kappa
    material_property_names = 'length_scale energy_scale sigma delta'
    function = '(energy_scale/length_scale)*(0.75*sigma*delta)'
  [../]
  
  [./mu_param] 
    type = ParsedMaterial
    f_name = mu
    material_property_names = 'length_scale energy_scale sigma delta'
    function = '(energy_scale/(length_scale)^3)*6*(sigma/delta)'
  [../]

  # Phase-specific Bulk Mobilities (Heat Treatment Conditions)
  [./M_si_1] # FCC
    type = GenericConstantMaterial
    prop_names = 'M_si_1'
    prop_values = '1.0e-14'
  [../]
  [./M_si_2] # HCP (Faster transformation)
    type = GenericConstantMaterial
    prop_names = 'M_si_2'
    prop_values = '1.0e-12'
  [../]
  [./M_si_3] # mu-phase (Slow, diffusion-limited)
    type = GenericConstantMaterial
    prop_names = 'M_si_3'
    prop_values = '1.0e-16'
  [../]

  # Phase-specific Grain Boundary Mobilities (~1000x bulk)
  [./M_gb_1]
    type = GenericConstantMaterial
    prop_names = 'M_gb_1'
    prop_values = '1.0e-11'
  [../]
  [./M_gb_2]
    type = GenericConstantMaterial
    prop_names = 'M_gb_2'
    prop_values = '1.0e-11'
  [../]
  [./M_gb_3]
    type = GenericConstantMaterial
    prop_names = 'M_gb_3'
    prop_values = '1.0e-13'
  [../]

  # Combined Mobility Function (Phase-dependent)
  [./ch_mobility]
    type = ParsedMaterial
    f_name = M
    material_property_names = 'length_scale energy_scale time_scale M_si_1 M_si_2 M_si_3 M_gb_1 M_gb_2 M_gb_3 h1 h2 h3'
    function = '((length_scale)^5/(energy_scale*time_scale)) * (h1*M_si_1 + h2*M_si_2 + h3*M_si_3 + (h1+h2+h3) * (h1*M_gb_1 + h2*M_gb_2 + h3*M_gb_3))'
  [../]

  [./interface_mobility]
    type = ParsedMaterial
    f_name = L
    constant_names = 'factor_L'
    constant_expressions = '1.0' 
    material_property_names = 'length_scale energy_scale time_scale mu_param kappa'
    function = '((length_scale)^3/(energy_scale*time_scale))*(16/3)*(mu_param*6.0e-14/kappa)*factor_L'
  [../]

  ####################################################################################################
  # Free Energy Functions (Scaled by 1000 for numerical stability, matching Al-Cu-Ni style)
  # Actual physical values are 1000x larger (e.g., -45 * 1000 = -45,000 J/mol)
  ####################################################################################################
  [./fch1] # FCC Matrix (Baseline phase)
    type = DerivativeParsedMaterial
    f_name = F1
    constant_names = 'factor_f1'
    constant_expressions = '1.0E+03'
    material_property_names = 'length_scale energy_scale molar_vol'
    args = 'c1a c1b'
    function = '(energy_scale/(length_scale)^3) * (-45.0 + 16.0*(c1a-0.64)^2 + 16.0*(c1b-0.25)^2) * factor_f1 / molar_vol'
  [../]

  [./fch2] # HCP Phase (Slightly more stable to drive FCC->HCP transformation)
    type = DerivativeParsedMaterial
    f_name = F2
    constant_names = 'factor_f2'
    constant_expressions = '1.0E+03'
    material_property_names = 'length_scale energy_scale molar_vol'
    args = 'c2a c2b'
    function = '(energy_scale/(length_scale)^3) * (-48.0 + 16.0*(c2a-0.68)^2 + 16.0*(c2b-0.22)^2) * factor_f2 / molar_vol'
  [../]

  [./fch3] # mu-phase (Highly stable W-rich intermetallic)
    type = DerivativeParsedMaterial
    f_name = F3
    constant_names = 'factor_f3'
    constant_expressions = '1.0E+03'
    material_property_names = 'length_scale energy_scale molar_vol'
    args = 'c3a c3b'
    function = '(energy_scale/(length_scale)^3) * (-60.0 + 100.0*(c3a-0.55)^2 + 100.0*(c3b-0.10)^2) * factor_f3 / molar_vol'
  [../]

  ####################################################################################################
  # Switching and Barrier Functions
  ####################################################################################################
  [./h1]
    type = SwitchingFunctionMultiPhaseMaterial
    h_name = h1
    all_etas = 'eta1 eta2 eta3'
    phase_etas = eta1
  [../]
  [./h2]
    type = SwitchingFunctionMultiPhaseMaterial
    h_name = h2
    all_etas = 'eta1 eta2 eta3'
    phase_etas = eta2
  [../]
  [./h3]
    type = SwitchingFunctionMultiPhaseMaterial
    h_name = h3
    all_etas = 'eta1 eta2 eta3'
    phase_etas = eta3
  [../]

  [./g1]
    type = BarrierFunctionMaterial
    g_order = SIMPLE
    eta = eta1
    function_name = g1
  [../]
  [./g2]
    type = BarrierFunctionMaterial
    g_order = SIMPLE
    eta = eta2
    function_name = g2
  [../]
  [./g3]
    type = BarrierFunctionMaterial
    g_order = SIMPLE
    eta = eta3
    function_name = g3
  [../]

  ####################################################################################################
  # Elastic Properties (Converted to eV/nm³: 1 GPa = 6.2415 eV/nm³)
  # symmetric9 order: C11, C12, C13, C22, C23, C33, C44, C55, C66
  ####################################################################################################
  [./elasticity_tensor_1] # FCC (Cubic: C11=C22=C33, C12=C13=C23, C44=C55=C66)
    type = ComputeElasticityTensor
    base_name = C_eta1
    fill_method = symmetric9
    C_ijkl = '1404.3 998.6 998.6 1404.3 998.6 1404.3 574.2 574.2 574.2'
  [../]
  [./strain_1]
    type = ComputeSmallStrain
    base_name = C_eta1
    eigenstrain_names = eigenstrain_1
    displacements = 'disp_x disp_y'
  [../]
  [./stress_1]
    type = ComputeLinearElasticStress
    base_name = C_eta1
  [../]
  [./eigenstrain_1]
    type = ComputeEigenstrain
    base_name = C_eta1
    eigen_base = '0.0'
    prefactor = 1.0
    eigenstrain_name = eigenstrain_1
  [../]
  [./fel_eta1]      
    type = ElasticEnergyMaterial
    args = 'disp_x disp_y'
    base_name = C_eta1
    f_name = fel1
    outputs = exodus
  [../]

  [./elasticity_tensor_2] # HCP (Hexagonal)
    type = ComputeElasticityTensor
    base_name = C_eta2
    fill_method = symmetric9
    C_ijkl = '1909.9 1029.8 636.6 1909.9 636.6 2228.2 468.1 468.1 443.1'
  [../]
  [./strain_2]
    type = ComputeSmallStrain
    base_name = C_eta2
    eigenstrain_names = eigenstrain_2
    displacements = 'disp_x disp_y'
  [../]
  [./stress_2]
    type = ComputeLinearElasticStress
    base_name = C_eta2
  [../]
  [./eigenstrain_2]
    type = ComputeEigenstrain
    base_name = C_eta2
    eigen_base = '0.0'
    prefactor = 1.0
    eigenstrain_name = eigenstrain_2
  [../]
  [./fel_eta2]
    type = ElasticEnergyMaterial
    args = 'disp_x disp_y'
    base_name = C_eta2
    f_name = fel2
    outputs = exodus
  [../]

  [./elasticity_tensor_3] # mu-phase (Approximated as Hexagonal TCP)
    type = ComputeElasticityTensor
    base_name = C_eta3
    fill_method = symmetric9
    C_ijkl = '2371.8 936.2 749.0 2371.8 749.0 2496.6 686.6 686.6 717.8'
  [../]
  [./strain_3]
    type = ComputeSmallStrain
    base_name = C_eta3
    eigenstrain_names = eigenstrain_3
    displacements = 'disp_x disp_y'
  [../]
  [./stress_3]
    type = ComputeLinearElasticStress
    base_name = C_eta3
  [../]
  [./eigenstrain_3]
    type = ComputeEigenstrain
    base_name = C_eta3
    eigen_base = '0.0'
    prefactor = 1.0
    eigenstrain_name = eigenstrain_3
  [../]
  [./fel_eta3]
    type = ElasticEnergyMaterial
    args = 'disp_x disp_y'
    base_name = C_eta3
    f_name = fel3
    outputs = exodus
  [../]

  # Global Stress Combination
  [./global_stress]
    type = MultiPhaseStressMaterial
    phase_base = 'C_eta1 C_eta2 C_eta3'
    h = 'h1 h2 h3'
    base_name = global
  [../]

  # Total Free Energy Summation per phase
  [./F_1]
    type = DerivativeSumMaterial
    f_name = F1_tot
    args = 'c1a c1b'
    sum_materials = 'fch1 fel1'
  [../]
  [./F_2]
    type = DerivativeSumMaterial
    f_name = F2_tot
    args = 'c2a c2b'
    sum_materials = 'fch2 fel2'
  [../]
  [./F_3]
    type = DerivativeSumMaterial
    f_name = F3_tot
    args = 'c3a c3b'
    sum_materials = 'fch3 fel3'
  [../]
[]

#########################################################################################
[Kernels]
  # KKS Chemical Potential Equality Constraints (Component A: Co)
  [./chempot12a]
    type = KKSPhaseChemicalPotential
    variable = c1a
    cb = c2a
    fa_name = F1_tot
    fb_name = F2_tot
  [../]
  [./chempot23a]
    type = KKSPhaseChemicalPotential
    variable = c2a
    cb = c3a
    fa_name = F2_tot
    fb_name = F3_tot
  [../]
  [./chempot31a]
    type = KKSPhaseChemicalPotential
    variable = c3a
    cb = c1a
    fa_name = F3_tot
    fb_name = F1_tot
  [../]

  # KKS Phase Concentration Constraint (Component A)
  [./phaseconcentration_a]
    type = KKSMultiPhaseConcentration
    variable = c1a
    cj = 'c1a c2a c3a'
    hj_names = 'h1 h2 h3'
    etas = 'eta1 eta2 eta3'
    c = ca
  [../]

  # KKS Chemical Potential Equality Constraints (Component B: Cr)
  [./chempot12b]
    type = KKSPhaseChemicalPotential
    variable = c1b
    cb = c2b
    fa_name = F1_tot
    fb_name = F2_tot
  [../]
  [./chempot23b]
    type = KKSPhaseChemicalPotential
    variable = c2b
    cb = c3b
    fa_name = F2_tot
    fb_name = F3_tot
  [../]
  [./chempot31b]
    type = KKSPhaseChemicalPotential
    variable = c3b
    cb = c1b
    fa_name = F3_tot
    fb_name = F1_tot
  [../]

  # KKS Phase Concentration Constraint (Component B)
  [./phaseconcentration_b]
    type = KKSMultiPhaseConcentration
    variable = c1b
    cj = 'c1b c2b c3b'
    hj_names = 'h1 h2 h3'
    etas = 'eta1 eta2 eta3'
    c = cb
  [../]

  # Cahn-Hilliard Diffusion Kernels (Global Composition)
  [./CHBulka]
    type = KKSSplitCHCRes
    variable = ca
    ca = c1a
    fa_name = F1_tot
    w = wa
  [../]
  [./dcdta]
    type = CoupledTimeDerivative
    variable = wa
    v = ca
  [../]
  [./ckernela]
    type = SplitCHWRes
    mob_name = M
    variable = wa
    args = 'eta1 eta2 eta3'
  [../]

  [./CHBulkb]
    type = KKSSplitCHCRes
    variable = cb
    ca = c1b
    fa_name = F1_tot
    w = wb
  [../]
  [./dcdtb]
    type = CoupledTimeDerivative
    variable = wb
    v = cb
  [../]
  [./ckernelb]
    type = SplitCHWRes
    mob_name = M
    variable = wb
    args = 'eta1 eta2 eta3'
  [../]

  # Allen-Cahn Kernels for eta1 (FCC)
  [./deta1dt]
    type = TimeDerivative
    variable = eta1
  [../]
  [./ACBulkF1]
    type = KKSMultiACBulkF
    variable = eta1
    Fj_names = 'F1_tot F2_tot F3_tot'
    hj_names = 'h1 h2 h3'
    gi_name = g1
    eta_i = eta1
    wi = 10.0
    args = 'c1a c2a c3a c1b c2b c3b eta2 eta3'
    mob_name = L
  [../]
  [./ACBulkC1a]
    type = KKSMultiACBulkC
    variable = eta1
    Fj_names = 'F1_tot F2_tot F3_tot'
    hj_names = 'h1 h2 h3'
    cj_names = 'c1a c2a c3a'
    eta_i = eta1
    args = 'eta2 eta3'
    mob_name = L
  [../]
  [./ACBulkC1b]
    type = KKSMultiACBulkC
    variable = eta1
    Fj_names = 'F1_tot F2_tot F3_tot'
    hj_names = 'h1 h2 h3'
    cj_names = 'c1b c2b c3b'
    eta_i = eta1
    args = 'eta2 eta3'
    mob_name = L
  [../]
  [./ACInterface1]
    type = ACInterface
    variable = eta1
    kappa_name = kappa
    mob_name = L
  [../]
  [./ACdfintdeta1]
    type = ACGrGrMulti
    variable = eta1
    v = 'eta2 eta3'
    gamma_names = 'gamma gamma'
    mob_name = L
    args = 'eta2 eta3'
  [../]

  # Allen-Cahn Kernels for eta2 (HCP)
  [./deta2dt]
    type = TimeDerivative
    variable = eta2
  [../]
  [./ACBulkF2]
    type = KKSMultiACBulkF
    variable = eta2
    Fj_names = 'F1_tot F2_tot F3_tot'
    hj_names = 'h1 h2 h3'
    gi_name = g2
    eta_i = eta2
    wi = 10.0
    args = 'c1a c2a c3a c1b c2b c3b eta1 eta3'
    mob_name = L
  [../]
  [./ACBulkC2a]
    type = KKSMultiACBulkC
    variable = eta2
    Fj_names = 'F1_tot F2_tot F3_tot'
    hj_names = 'h1 h2 h3'
    cj_names = 'c1a c2a c3a'
    eta_i = eta2
    args = 'eta1 eta3'
    mob_name = L
  [../]
  [./ACBulkC2b]
    type = KKSMultiACBulkC
    variable = eta2
    Fj_names = 'F1_tot F2_tot F3_tot'
    hj_names = 'h1 h2 h3'
    cj_names = 'c1b c2b c3b'
    eta_i = eta2
    args = 'eta1 eta3'
    mob_name = L
  [../]
  [./ACInterface2]
    type = ACInterface
    variable = eta2
    kappa_name = kappa
    mob_name = L
  [../]
  [./ACdfintdeta2]
    type = ACGrGrMulti
    variable = eta2
    v = 'eta1 eta3'
    gamma_names = 'gamma gamma'
    mob_name = L
    args = 'eta1 eta3'
  [../]

  # Allen-Cahn Kernels for eta3 (mu-phase)
  [./deta3dt]
    type = TimeDerivative
    variable = eta3
  [../]
  [./ACBulkF3]
    type = KKSMultiACBulkF
    variable = eta3
    Fj_names = 'F1_tot F2_tot F3_tot'
    hj_names = 'h1 h2 h3'
    gi_name = g3
    eta_i = eta3
    wi = 10.0
    args = 'c1a c2a c3a c1b c2b c3b eta1 eta2'
    mob_name = L
  [../]
  [./ACBulkC3a]
    type = KKSMultiACBulkC
    variable = eta3
    Fj_names = 'F1_tot F2_tot F3_tot'
    hj_names = 'h1 h2 h3'
    cj_names = 'c1a c2a c3a'
    eta_i = eta3
    args = 'eta1 eta2'
    mob_name = L
  [../]
  [./ACBulkC3b]
    type = KKSMultiACBulkC
    variable = eta3
    Fj_names = 'F1_tot F2_tot F3_tot'
    hj_names = 'h1 h2 h3'
    cj_names = 'c1b c2b c3b'
    eta_i = eta3
    args = 'eta1 eta2'
    mob_name = L
  [../]
  [./ACInterface3]
    type = ACInterface
    variable = eta3
    kappa_name = kappa
    mob_name = L
  [../]
  [./ACdfintdeta3]
    type = ACGrGrMulti
    variable = eta3
    v = 'eta1 eta2'
    gamma_names = 'gamma gamma'
    mob_name = L
    args = 'eta1 eta2'
  [../]

  # Elasticity Kernel
  [./TensorMechanics]
    displacements = 'disp_x disp_y'
    base_name = global
    planar_formulation = PLANE_STRAIN
    use_displaced_mesh = false
  [../]
[]

#########################################################################################
[AuxKernels]
  [./bnds]
    type = BndsCalcAux
    variable = bnds
    var_name_base = eta
    op_num = 3
    v = 'eta1 eta2 eta3'
  [../]

  [./Energy_total]
    type = KKSMultiFreeEnergy
    Fj_names = 'F1_tot F2_tot F3_tot'
    hj_names = 'h1 h2 h3'
    gj_names = 'g1 g2 g3'
    variable = Energy
    w = 1
    interfacial_vars = 'eta1 eta2 eta3'
    kappa_names = 'kappa kappa kappa'
  [../]

  # Visualizing global composition reconstruction
  # FIXED: Added material_property_names so ParsedAux recognizes h1, h2, h3
  [./ca_hsquarec]
    type = ParsedAux
    variable = gr_ca
    coupled_variables = 'c1a c2a c3a'
    material_property_names = 'h1 h2 h3'
    function = 'h1*c1a + h2*c2a + h3*c3a'
  [../]

  [./cb_hsquarec]
    type = ParsedAux
    variable = gr_cb
    coupled_variables = 'c1b c2b c3b'
    material_property_names = 'h1 h2 h3'
    function = 'h1*c1b + h2*c2b + h3*c3b'
  [../]

  # Stress visualization
  [./von_mises_kernel]
    type = RankTwoScalarAux
    variable = von_mises
    rank_two_tensor = global_stress
    execute_on = timestep_end
    scalar_type = VonMisesStress
  [../]
  [./matl_sigma11]
    type = RankTwoAux
    rank_two_tensor = global_stress
    index_i = 0
    index_j = 0
    variable = sigma11
  [../]
  [./matl_sigma22]
    type = RankTwoAux
    rank_two_tensor = global_stress
    index_i = 1
    index_j = 1
    variable = sigma22
  [../]
  [./matl_sigma12]
    type = RankTwoAux
    rank_two_tensor = global_stress
    index_i = 0
    index_j = 1
    variable = sigma12
  [../]
[]

#########################################################################################
[Postprocessors]
  [area_fcc_eta1]
    type = ElementIntegralMaterialProperty
    mat_prop = h1
    execute_on = 'Initial TIMESTEP_END'
  [../]
  [area_hcp_eta2]
    type = ElementIntegralMaterialProperty
    mat_prop = h2
    execute_on = 'Initial TIMESTEP_END'
  [../]
  [area_mu_eta3]
    type = ElementIntegralMaterialProperty
    mat_prop = h3
    execute_on = 'Initial TIMESTEP_END'
  [../]
[]

#########################################################################################
[Executioner]
  type = Transient
  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type'
  petsc_options_value = 'asm ilu nonzero'
  l_max_its = 50
  nl_max_its = 20
  l_tol = 1.0e-4
  nl_rel_tol = 1.0e-10
  nl_abs_tol = 1.0e-11
  end_time = 1.0E+22 # Adjust based on desired heat treatment time scale

  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1.0E+06
    cutback_factor = 0.8
    growth_factor = 1.1
    optimal_iterations = 7
  [../]

  [./Adaptivity]
    interval = 10
    initial_adaptivity = 3
    refine_fraction = 0.9
    coarsen_fraction = 0.1
    max_h_level = 2
    weight_names = 'eta1 eta2 eta3'
    weight_values = '1 1 1'
  [../]
[]

[Preconditioning]
  active = 'full'
  [./full]
    type = SMP
    full = true
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  file_base = exodus_files/Mediloy_SCo_3phase
  interval = 10
  checkpoint = true
[]

[Debug]
  show_var_residual_norms = true
[]
