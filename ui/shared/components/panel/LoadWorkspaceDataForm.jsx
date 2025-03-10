import React from 'react'
import PropTypes from 'prop-types'
import { Header, Segment, Message } from 'semantic-ui-react'
import { connect } from 'react-redux'

import { HttpRequestHelper } from 'shared/utils/httpRequestHelper'

import {
  FILE_FIELD_NAME,
  PROJECT_DESC_FIELD,
  GENOME_VERSION_FIELD,
  FAMILY_FIELD_ID,
  INDIVIDUAL_FIELD_ID,
  FILE_FORMATS,
  INDIVIDUAL_CORE_EXPORT_DATA,
  INDIVIDUAL_ID_EXPORT_DATA,
  INDIVIDUAL_FIELD_SEX,
  INDIVIDUAL_FIELD_AFFECTED,
  SAMPLE_TYPE_OPTIONS,
} from 'shared/utils/constants'
import { validateUploadedFile } from 'shared/components/form/XHRUploaderField'
import BulkUploadForm from 'shared/components/form/BulkUploadForm'
import FormWizard from 'shared/components/form/FormWizard'
import { validators } from 'shared/components/form/FormHelpers'
import { BooleanCheckbox, RadioGroup } from 'shared/components/form/Inputs'
import PhiWarningUploadField from 'shared/components/form/PhiWarningUploadField'
import { RECEIVE_DATA } from 'redux/utils/reducerUtils'
import { getAnvilLoadingDelayDate } from 'redux/selectors'
import AnvilFileSelector from 'shared/components/form/AnvilFileSelector'

const VCF_DOCUMENTATION_URL = 'https://storage.googleapis.com/seqr-reference-data/seqr-vcf-info.pdf'

const NON_ID_REQUIRED_FIELDS = [INDIVIDUAL_FIELD_SEX, INDIVIDUAL_FIELD_AFFECTED]

const FIELD_DESCRIPTIONS = {
  [FAMILY_FIELD_ID]: 'Family ID',
  [INDIVIDUAL_FIELD_ID]: 'Individual ID (needs to match the VCF ids)',
  [INDIVIDUAL_FIELD_SEX]: 'Male, Female, or Unknown',
  [INDIVIDUAL_FIELD_AFFECTED]: 'Affected, Unaffected, or Unknown',
}
const REQUIRED_FIELDS = [
  ...INDIVIDUAL_ID_EXPORT_DATA,
  ...INDIVIDUAL_CORE_EXPORT_DATA.filter(({ field }) => NON_ID_REQUIRED_FIELDS.includes(field)),
].map(config => ({ ...config, description: FIELD_DESCRIPTIONS[config.field] }))

const OPTIONAL_FIELDS = INDIVIDUAL_CORE_EXPORT_DATA.filter(({ field }) => !NON_ID_REQUIRED_FIELDS.includes(field))

const BLANK_EXPORT = {
  filename: 'individuals_template',
  rawData: [],
  headers: [...INDIVIDUAL_ID_EXPORT_DATA, ...INDIVIDUAL_CORE_EXPORT_DATA].map(config => config.header),
  processRow: val => val,
}

const DEMO_EXPORT = {
  ...BLANK_EXPORT,
  filename: 'demo_individuals',
  rawData: [
    ['FAM1', 'FAM1_1', 'FAM1_2', 'FAM1_3', 'Male', 'Affected', ''],
    ['FAM1', 'FAM1_4', 'FAM1_2', 'FAM1_3', '', 'Affected', 'an affected sibling'],
    ['FAM1', 'FAM1_2', '', '', 'Male', 'Unaffected', ''],
    ['FAM1', 'FAM1_3', '', '', 'Female', '', 'affected status of mother unknown'],
    ['FAM2', 'FAM2_1', '', '', 'Female', 'Affected', 'a proband-only family'],
  ],
}

const PHI_DISCALIMER = `including in any of the IDs or in the notes. PHI includes names, contact information, 
birth dates, and any other identifying information`

const UploadPedigreeField = React.memo(({ name, error }) => (
  <div className={`${error ? 'error' : ''} field`}>
    <label key="uploadLabel">Upload Pedigree Data</label>
    <Segment key="uploadForm" color={error ? 'red' : null}>
      <PhiWarningUploadField fileDescriptor="pedigree file" disclaimerDetail={PHI_DISCALIMER}>
        <BulkUploadForm
          name={name}
          blankExportConfig={BLANK_EXPORT}
          exportConfig={DEMO_EXPORT}
          templateLinkContent="an example pedigree"
          requiredFields={REQUIRED_FIELDS}
          optionalFields={OPTIONAL_FIELDS}
          uploadFormats={FILE_FORMATS}
          actionDescription="load individual data from an AnVIL workspace to a new seqr project"
          url="/api/upload_temp_file"
        />
      </PhiWarningUploadField>
    </Segment>
  </div>
))

UploadPedigreeField.propTypes = {
  name: PropTypes.string,
  error: PropTypes.bool,
}

const UPLOAD_PEDIGREE_FIELD = {
  name: FILE_FIELD_NAME,
  validate: validateUploadedFile,
  component: UploadPedigreeField,
}

const AGREE_CHECKBOX = {
  name: 'agreeSeqrAccess',
  component: BooleanCheckbox,
  label: 'By proceeding with seqr loading, I agree to grant seqr access to the data in this workspace',
  validate: validators.required,
}

const SAMPLE_TYPE_FIELD = {
  name: 'sampleType',
  label: 'Sample Type',
  component: RadioGroup,
  options: SAMPLE_TYPE_OPTIONS.slice(0, 2),
  validate: validators.required,
}

const DATA_BUCK_FIELD = {
  name: 'dataPath',
  label: 'Path to the Joint Called VCF',
  labelHelp: 'File path for a joint called VCF available in the workspace "Files".',
  component: AnvilFileSelector,
  validate: validators.required,
}

const REQUIRED_GENOME_FIELD = { ...GENOME_VERSION_FIELD, validate: validators.required }

const postWorkspaceValues = (path, formatVals, formatUrl) => onSuccess => (
  { workspaceNamespace, workspaceName, ...values },
) => (
  new HttpRequestHelper(
    formatUrl ? formatUrl(values) : `/api/create_project_from_workspace/${workspaceNamespace}/${workspaceName}/${path}`,
    onSuccess,
  ).post(formatVals ? formatVals(values) : values)
)

const postSubmitValues = formatUrl => postWorkspaceValues(
  'submit', ({ uploadedFile, ...values }) => ({ ...values, uploadedFileId: uploadedFile.uploadedFileId }), formatUrl,
)

const createProjectFromWorkspace = postSubmitValues()((responseJson) => {
  window.location.href = `/project/${responseJson.projectGuid}/project_page`
})

const addDataFromWorkspace = values => dispatch => postSubmitValues(
  ({ projectGuid }) => (`/api/project/${projectGuid}/add_workspace_data`),
)((responseJson) => {
  dispatch({ type: RECEIVE_DATA, updatesById: responseJson })
})(values)

const GRANT_ACCESS_PAGE = { fields: [AGREE_CHECKBOX], onPageSubmit: postWorkspaceValues('grant_access') }
const VALIDATE_VCF_PAGE = {
  fields: [DATA_BUCK_FIELD, SAMPLE_TYPE_FIELD, REQUIRED_GENOME_FIELD],
  onPageSubmit: postWorkspaceValues('validate_vcf'),
}

const NEW_PROJECT_WIZARD_PAGES = [
  GRANT_ACCESS_PAGE,
  VALIDATE_VCF_PAGE,
  { fields: [PROJECT_DESC_FIELD, UPLOAD_PEDIGREE_FIELD] },
]

const ADD_DATA_WIZARD_PAGES = [
  GRANT_ACCESS_PAGE,
  { ...VALIDATE_VCF_PAGE, fields: [DATA_BUCK_FIELD] },
  { fields: [UPLOAD_PEDIGREE_FIELD] },
]

const LoadWorkspaceDataForm = React.memo(({ params, onAddData, createProject, anvilLoadingDelayDate, ...props }) => (
  <div>
    <Header size="large" textAlign="center">
      {`Load data to seqr from AnVIL Workspace "${params.workspaceNamespace}/${params.workspaceName}"`}
    </Header>
    <Segment basic textAlign="center">
      <Message info compact>
        In order to load your data to seqr, you must have a joint called VCF available in your workspace. For more
        information about generating and validating this file,
        see &nbsp;
        <b><a href={VCF_DOCUMENTATION_URL} target="_blank" rel="noreferrer">this documentation</a></b>
      </Message>
      {anvilLoadingDelayDate ? (
        <Message
          error
          compact
          header="Planned Data Loading Delay"
          content={
            <span>
              The Broad Institute is currently having an internal retreat or is closed for winter break.
              <br />
              As a result, any requests for data to be loaded as of &nbsp;
              <b>{new Date(`${anvilLoadingDelayDate}T00:00`).toDateString()}</b>
              &nbsp; will be delayed until the &nbsp;
              <b>
                2nd week of January &nbsp;
                {new Date(`${anvilLoadingDelayDate}T00:00`).getFullYear() + 1}
              </b>
              <br />
              We appreciate your understanding and support of our research team taking some well-deserved time off
              and hope you also have a nice break.
            </span>
          }
        />
      ) : null}
    </Segment>
    <FormWizard
      {...props}
      onSubmit={createProject ? createProjectFromWorkspace : onAddData}
      pages={params.projectGuid ? ADD_DATA_WIZARD_PAGES : NEW_PROJECT_WIZARD_PAGES}
      initialValues={params}
      size="small"
      noModal
    />
    <p>
      Need help? please submit &nbsp;
      <a href="https://github.com/broadinstitute/seqr/issues/new?labels=bug&template=bug_report.md">GitHub Issues</a>
      , &nbsp; or &nbsp;
      <a href="mailto:seqr@broadinstitute.org" target="_blank" rel="noreferrer">
        Email Us
      </a>
    </p>
  </div>
))

LoadWorkspaceDataForm.propTypes = {
  params: PropTypes.object.isRequired,
  anvilLoadingDelayDate: PropTypes.string,
  createProject: PropTypes.bool,
  onAddData: PropTypes.func,
}

const mapStateToProps = state => ({
  anvilLoadingDelayDate: getAnvilLoadingDelayDate(state),
})

const mapDispatchToProps = {
  onAddData: addDataFromWorkspace,
}

export default connect(mapStateToProps, mapDispatchToProps)(LoadWorkspaceDataForm)
