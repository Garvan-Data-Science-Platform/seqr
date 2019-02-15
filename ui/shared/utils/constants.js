import { Form } from 'semantic-ui-react'

import { validators } from '../components/form/ReduxFormWrapper'
import { BooleanCheckbox, RadioGroup } from '../components/form/Inputs'
import BaseFieldView from '../components/panel/view-fields/BaseFieldView'
import OptionFieldView from '../components/panel/view-fields/OptionFieldView'
import PlainTextFieldView from '../components/panel/view-fields/PlainTextFieldView'

import { stripMarkdown } from './stringUtils'


export const GENOME_VERSION_37 = '37'
export const GENOME_VERSION_OPTIONS = [
  { value: GENOME_VERSION_37, text: 'GRCh37' },
  { value: '38', text: 'GRCh38' },
]

// PROJECT FIELDS

export const PROJECT_FIELDS = [
  { name: 'name', label: 'Project Name', placeholder: 'Name', validate: validators.required, autoFocus: true },
  { name: 'description', label: 'Project Description', placeholder: 'Description' },
  { name: 'genomeVersion', label: 'Genome Version', component: RadioGroup, options: GENOME_VERSION_OPTIONS },
]


// SAMPLES

export const DATASET_TYPE_READ_ALIGNMENTS = 'ALIGN'
export const DATASET_TYPE_VARIANT_CALLS = 'VARIANTS'

export const SAMPLE_STATUS_LOADED = 'loaded'

export const SAMPLE_TYPE_EXOME = 'WES'
export const SAMPLE_TYPE_GENOME = 'WGS'
export const SAMPLE_TYPE_RNA = 'RNA'

export const SAMPLE_TYPE_OPTIONS = [
  { value: SAMPLE_TYPE_EXOME, text: 'Exome' },
  { value: SAMPLE_TYPE_GENOME, text: 'Genome' },
  { value: SAMPLE_TYPE_RNA, text: 'RNA-seq' },
]

export const SAMPLE_TYPE_LOOKUP = SAMPLE_TYPE_OPTIONS.reduce(
  (acc, opt) => ({
    ...acc,
    ...{ [opt.value]: opt },
  }), {},
)

// ANALYSIS STATUS

export const FAMILY_STATUS_SOLVED = 'S'
export const FAMILY_STATUS_SOLVED_KNOWN_GENE_KNOWN_PHENOTYPE = 'S_kgfp'
export const FAMILY_STATUS_SOLVED_KNOWN_GENE_DIFFERENT_PHENOTYPE = 'S_kgdp'
export const FAMILY_STATUS_SOLVED_NOVEL_GENE = 'S_ng'
export const FAMILY_STATUS_STRONG_CANDIDATE_KNOWN_GENE_KNOWN_PHENOTYPE = 'Sc_kgfp'
export const FAMILY_STATUS_STRONG_CANDIDATE_KNOWN_GENE_DIFFERENT_PHENOTYPE = 'Sc_kgdp'
export const FAMILY_STATUS_STRONG_CANDIDATE_NOVEL_GENE = 'Sc_ng'
export const FAMILY_STATUS_REVIEWED_PURSUING_CANDIDATES = 'Rcpc'
export const FAMILY_STATUS_REVIEWED_NO_CLEAR_CANDIDATE = 'Rncc'
export const FAMILY_STATUS_ANALYSIS_IN_PROGRESS = 'I'
export const FAMILY_STATUS_WAITING_FOR_DATA = 'Q'

export const FAMILY_ANALYSIS_STATUS_OPTIONS = [
  { value: FAMILY_STATUS_SOLVED, color: '#4CAF50', name: 'Solved' },
  { value: FAMILY_STATUS_SOLVED_KNOWN_GENE_KNOWN_PHENOTYPE, color: '#4CAF50', name: 'Solved - known gene for phenotype' },
  { value: FAMILY_STATUS_SOLVED_KNOWN_GENE_DIFFERENT_PHENOTYPE, color: '#4CAF50', name: 'Solved - gene linked to different phenotype' },
  { value: FAMILY_STATUS_SOLVED_NOVEL_GENE, color: '#4CAF50', name: 'Solved - novel gene' },
  { value: FAMILY_STATUS_STRONG_CANDIDATE_KNOWN_GENE_KNOWN_PHENOTYPE, color: '#CDDC39', name: 'Strong candidate - known gene for phenotype' },
  { value: FAMILY_STATUS_STRONG_CANDIDATE_KNOWN_GENE_DIFFERENT_PHENOTYPE, color: '#CDDC39', name: 'Strong candidate - gene linked to different phenotype' },
  { value: FAMILY_STATUS_STRONG_CANDIDATE_NOVEL_GENE, color: '#CDDC39', name: 'Strong candidate - novel gene' },
  { value: FAMILY_STATUS_REVIEWED_PURSUING_CANDIDATES, color: '#CDDC39', name: 'Reviewed, currently pursuing candidates' },
  { value: FAMILY_STATUS_REVIEWED_NO_CLEAR_CANDIDATE, color: '#EF5350', name: 'Reviewed, no clear candidate' },
  { value: FAMILY_STATUS_ANALYSIS_IN_PROGRESS, color: '#4682B4', name: 'Analysis in Progress' },
  { value: FAMILY_STATUS_WAITING_FOR_DATA, color: '#FFC107', name: 'Waiting for data' },
]

// FAMILY FIELDS

export const FAMILY_FIELD_ID = 'familyId'
export const FAMILY_DISPLAY_NAME = 'displayName'
export const FAMILY_FIELD_DESCRIPTION = 'description'
export const FAMILY_FIELD_ANALYSIS_STATUS = 'analysisStatus'
export const FAMILY_FIELD_ANALYSED_BY = 'analysedBy'
export const FAMILY_FIELD_ANALYSIS_NOTES = 'analysisNotes'
export const FAMILY_FIELD_ANALYSIS_SUMMARY = 'analysisSummary'
export const FAMILY_FIELD_INTERNAL_NOTES = 'internalCaseReviewNotes'
export const FAMILY_FIELD_INTERNAL_SUMMARY = 'internalCaseReviewSummary'
export const FAMILY_FIELD_FIRST_SAMPLE = 'firstSample'
export const FAMILY_FIELD_CODED_PHENOTYPE = 'codedPhenotype'
export const FAMILY_FIELD_OMIM_NUMBER = 'postDiscoveryOmimNumber'
export const FAMILY_FIELD_PEDIGREE = 'pedigreeImage'
export const FAMILY_FIELD_CREATED_DATE = 'createdDate'

export const FAMILY_FIELD_RENDER_LOOKUP = {
  [FAMILY_FIELD_DESCRIPTION]: { name: 'Family Description' },
  [FAMILY_FIELD_ANALYSIS_STATUS]: { name: 'Analysis Status', component: OptionFieldView },
  [FAMILY_FIELD_ANALYSED_BY]: {
    name: 'Analysed By',
    component: BaseFieldView,
    submitArgs: { familyField: 'analysed_by' },
  },
  [FAMILY_FIELD_FIRST_SAMPLE]: { name: 'Data Loaded?', component: BaseFieldView },
  [FAMILY_FIELD_ANALYSIS_NOTES]: { name: 'Notes' },
  [FAMILY_FIELD_ANALYSIS_SUMMARY]: { name: 'Analysis Summary' },
  [FAMILY_FIELD_CODED_PHENOTYPE]: { name: 'Coded Phenotype', component: PlainTextFieldView },
  [FAMILY_FIELD_OMIM_NUMBER]: { name: 'Post-discovery OMIM #', component: BaseFieldView },
  [FAMILY_FIELD_INTERNAL_NOTES]: { name: 'Internal Notes', internal: true },
  [FAMILY_FIELD_INTERNAL_SUMMARY]: { name: 'Internal Summary', internal: true },
}

export const FAMILY_DETAIL_FIELDS = [
  { id: FAMILY_FIELD_DESCRIPTION, canEdit: true },
  { id: FAMILY_FIELD_ANALYSIS_STATUS, canEdit: true },
  { id: FAMILY_FIELD_ANALYSED_BY, canEdit: true },
  { id: FAMILY_FIELD_ANALYSIS_NOTES, canEdit: true },
  { id: FAMILY_FIELD_ANALYSIS_SUMMARY, canEdit: true },
  { id: FAMILY_FIELD_CODED_PHENOTYPE, canEdit: true },
  { id: FAMILY_FIELD_OMIM_NUMBER, canEdit: true },
]

// INDIVIDUAL FIELDS

export const SEX_OPTIONS = [
  { value: 'M', text: 'Male' },
  { value: 'F', text: 'Female' },
  { value: 'U', text: '?' },
]

export const SEX_LOOKUP = SEX_OPTIONS.reduce(
  (acc, opt) => ({
    ...acc,
    ...{ [opt.value]: opt.text === '?' ? 'Unknown' : opt.text },
  }), {},
)

export const AFFECTED_OPTIONS = [
  { value: 'A', text: 'Affected' },
  { value: 'N', text: 'Unaffected' },
  { value: 'U', text: '?' },
]

export const AFFECTED_LOOKUP = AFFECTED_OPTIONS.reduce(
  (acc, opt) => ({
    ...acc,
    ...{ [opt.value]: opt.text === '?' ? 'Unknown' : opt.text },
  }), {},
)

export const INDIVIDUAL_FIELD_ID = 'individualId'
export const INDIVIDUAL_FIELD_PATERNAL_ID = 'paternalId'
export const INDIVIDUAL_FIELD_MATERNAL_ID = 'maternalId'
export const INDIVIDUAL_FIELD_SEX = 'sex'
export const INDIVIDUAL_FIELD_AFFECTED = 'affected'
export const INDIVIDUAL_FIELD_NOTES = 'notes'

export const INDIVIDUAL_FIELD_CONFIGS = {
  [FAMILY_FIELD_ID]: { label: 'Family ID' },
  [INDIVIDUAL_FIELD_ID]: { label: 'Individual ID' },
  [INDIVIDUAL_FIELD_PATERNAL_ID]: { label: 'Paternal ID', description: 'Individual ID of the father' },
  [INDIVIDUAL_FIELD_MATERNAL_ID]: { label: 'Maternal ID', description: 'Individual ID of the mother' },
  [INDIVIDUAL_FIELD_SEX]: {
    label: 'Sex',
    format: sex => SEX_LOOKUP[sex],
    width: 3,
    description: 'Male or Female, leave blank if unknown',
    formFieldProps: { component: RadioGroup, options: SEX_OPTIONS },
  },
  [INDIVIDUAL_FIELD_AFFECTED]: {
    label: 'Affected Status',
    format: affected => AFFECTED_LOOKUP[affected],
    width: 4,
    description: 'Affected or Unaffected, leave blank if unknown',
    formFieldProps: { component: RadioGroup, options: AFFECTED_OPTIONS },
  },
  [INDIVIDUAL_FIELD_NOTES]: { label: 'Notes', format: stripMarkdown, description: 'free-text notes related to this individual' },
}


export const INDIVIDUAL_HPO_EXPORT_DATA = [
  {
    header: 'HPO Terms (present)',
    field: 'phenotipsData',
    format: phenotipsData => (
      (phenotipsData || {}).features ?
        phenotipsData.features.filter(feature => feature.observed === 'yes').map(feature => `${feature.id} (${feature.label})`).join('; ') :
        ''
    ),
    description: 'comma-separated list of HPO Terms for present phenotypes in this individual',
  },
  {
    header: 'HPO Terms (absent)',
    field: 'phenotipsData',
    format: phenotipsData => (
      (phenotipsData || {}).features ?
        phenotipsData.features.filter(feature => feature.observed === 'no').map(feature => `${feature.id} (${feature.label})`).join('; ') :
        ''
    ),
    description: 'comma-separated list of HPO Terms for phenotypes not present in this individual',
  },
]

// CLINVAR

export const CLINSIG_SEVERITY = {
  // clinvar
  pathogenic: 1,
  'risk factor': 0,
  risk_factor: 0,
  'likely pathogenic': 1,
  'pathogenic/likely_pathogenic': 1,
  likely_pathogenic: 1,
  benign: -1,
  'likely benign': -1,
  'benign/likely_benign': -1,
  likely_benign: -1,
  protective: -1,
  // hgmd
  DM: 1,
  'DM?': 0,
  FPV: 0,
  FP: 0,
  DFP: 0,
  DP: 0,
}


// LOCUS LISTS

export const LOCUS_LIST_IS_PUBLIC_FIELD_NAME = 'isPublic'
export const LOCUS_LIST_LAST_MODIFIED_FIELD_NAME = 'lastModifiedDate'
export const LOCUS_LIST_CURATOR_FIELD_NAME = 'createdBy'

export const LOCUS_LIST_FIELDS = [
  {
    name: 'name',
    label: 'List Name',
    labelHelp: 'A descriptive name for this gene list',
    validate: value => (value ? undefined : 'Name is required'),
    width: 3,
    isEditable: true,
  },
  { name: 'numEntries', label: 'Entries', width: 1 },
  {
    name: 'description',
    label: 'Description',
    labelHelp: 'Some background on how this list is curated',
    width: 9,
    isEditable: true,
  },
  {
    name: LOCUS_LIST_LAST_MODIFIED_FIELD_NAME,
    label: 'Last Updated',
    width: 3,
    fieldDisplay: lastModifiedDate => new Date(lastModifiedDate).toLocaleString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric', hour: 'numeric', minute: 'numeric' }),
  },
  { name: LOCUS_LIST_CURATOR_FIELD_NAME, label: 'Curator', width: 3 },
  {
    name: LOCUS_LIST_IS_PUBLIC_FIELD_NAME,
    label: 'Public List',
    labelHelp: 'Should other seqr users be able to use this gene list?',
    component: RadioGroup,
    options: [{ value: true, text: 'Yes' }, { value: false, text: 'No' }],
    fieldDisplay: isPublic => (isPublic ? 'Yes' : 'No'),
    width: 2,
    isEditable: true,
  },
]

export const LOCUS_LIST_ITEMS_FIELD = {
  name: 'rawItems',
  label: 'Genes/ Intervals',
  labelHelp: 'A list of genes and intervals. Can be separated by commas or whitespace. Intervals should be in the form <chrom>:<start>-<end>',
  fieldDisplay: () => null,
  isEditable: true,
  component: Form.TextArea,
  rows: 12,
  validate: value => (value ? undefined : 'Genes and/or intervals are required'),
  additionalFormFields: [
    {
      name: 'intervalGenomeVersion',
      component: RadioGroup,
      options: GENOME_VERSION_OPTIONS,
      label: 'Genome Version',
      labelHelp: 'The genome version associated with intervals. Only required if the list contains intervals',
      validate: (value, allValues) => (
        (value || !(allValues.rawItems || '').match(/([^\s-]*):(\d*)-(\d*)/)) ? undefined :
          'Genome version is required for lists with intervals'
      ),
    },
    {
      name: 'ignoreInvalidItems',
      component: BooleanCheckbox,
      label: 'Ignore invalid genes and intervals',
    },
  ],
}

export const EXCLUDED_TAG_NAME = 'Excluded'
export const REVIEW_TAG_NAME = 'Review'
export const KNOWN_GENE_FOR_PHENOTYPE_TAG_NAME = 'Known gene for phenotype'
export const DISCOVERY_CATEGORY_NAME = 'CMG Discovery Tags'
