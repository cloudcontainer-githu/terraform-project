pipeline {
  agent any

  environment {
    AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
  }

  parameters {
    choice(name: 'ACTION', choices: ['init', 'validate', 'plan', 'apply', 'destroy'], description: 'Terraform action to perform')
  }

  stages {

    stage('Initialize') {
      when {
        anyOf {
          expression { params.ACTION == 'init' }
          expression { params.ACTION == 'validate' }
          expression { params.ACTION == 'plan' }
          expression { params.ACTION == 'apply' }
          expression { params.ACTION == 'destroy' }
        }
      }
      steps {
        script {
          try {
            sh 'terraform init -reconfigure'
          } catch (err) {
            echo "Terraform init failed: ${err}"
            currentBuild.result = 'FAILURE'
            error("Stopping pipeline due to init failure")
          }
        }
      }
    }

    stage('Validate') {
      when {
        expression { params.ACTION == 'validate' }
      }
      steps {
        script {
          try {
            sh 'terraform validate'
          } catch (err) {
            echo "Terraform validate failed: ${err}"
            currentBuild.result = 'FAILURE'
            error("Stopping pipeline due to validate failure")
          }
        }
      }
    }

    stage('Plan') {
      when {
        expression { params.ACTION == 'plan' }
      }
      steps {
        script {
          try {
            sh 'terraform plan -out=tfplan'
          } catch (err) {
            echo "Terraform plan failed: ${err}"
            currentBuild.result = 'FAILURE'
            error("Stopping pipeline due to plan failure")
          }
        }
      }
    }

    stage('Approval for Apply') {
      when {
        expression { params.ACTION == 'apply' }
      }
      steps {
        input message: "Approve Apply?", ok: "Yes, apply"
      }
    }

    stage('Apply') {
      when {
        expression { params.ACTION == 'apply' }
      }
      steps {
        script {
          try {
            sh 'terraform apply -auto-approve tfplan'
          } catch (err) {
            echo "Terraform apply failed: ${err}"
            currentBuild.result = 'FAILURE'
            error("Stopping pipeline due to apply failure")
          }
        }
      }
    }

    stage('Plan for Destroy') {
      when {
        expression { params.ACTION == 'destroy' }
      }
      steps {
        script {
          try {
            sh 'terraform plan -destroy -out=tfdestroy'
          } catch (err) {
            echo "Terraform destroy plan failed: ${err}"
            currentBuild.result = 'FAILURE'
            error("Stopping pipeline due to destroy plan failure")
          }
        }
      }
    }

    stage('Approval for Destroy') {
      when {
        expression { params.ACTION == 'destroy' }
      }
      steps {
        script {
          try {
            input message: "Are you sure you want to destroy?", ok: "Yes, destroy"
          } catch (err) {
            echo "Destroy approval not granted: ${err}"
            currentBuild.result = 'ABORTED'
          }
        }
      }
    }

    stage('Destroy') {
      when {
        allOf {
          expression { params.ACTION == 'destroy' }
          expression { currentBuild.result != 'ABORTED' }
        }
      }
      steps {
        script {
          try {
            sh 'terraform destroy -auto-approve'
          } catch (err) {
            echo "Terraform destroy failed: ${err}"
            currentBuild.result = 'FAILURE'
            error("Stopping pipeline due to destroy failure")
          }
        }
      }
    }

  }

  post {
    always {
      echo "Pipeline completed with status: ${currentBuild.result}"
    }
    failure {
      echo "Pipeline failed. Check the stage logs above."
    }
    aborted {
      echo "Pipeline was aborted (e.g. approval not granted)."
    }
  }
}
