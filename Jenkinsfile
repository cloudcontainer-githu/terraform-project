
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
        expression { params.ACTION == 'init' }
      }
      steps {
        sh 'terraform init'
      }
    }

    stage('Validate') {
      when {
        expression { params.ACTION == 'validate' }
      }
      steps {
        sh 'terraform validate'
      }
    }

    stage('Plan') {
      when {
        expression { params.ACTION == 'plan' }
      }
      steps {
        sh 'terraform plan'
      }
    }

    stage('Approval for Apply') {
      when {
        expression { params.ACTION == 'apply' }
      }
      steps {
        input(message: "Approve Deployment?", ok: "Yes, deploy")
      }
    }

    stage('Apply') {
      when {
        expression { params.ACTION == 'apply' }
      }
      steps {
        sh 'terraform apply -auto-approve'
      }
    }

    stage('Plan for Destroy') {
      when {
        expression { params.ACTION == 'destroy' }
      }
      steps {
        sh 'terraform plan -destroy'
      }
    }

    stage('Approval for Destroy') {
      when {
        expression { params.ACTION == 'destroy' }
      }
      steps {
        input(message: "Are you sure you want to destroy? Review the plan above.", ok: "Yes, destroy")
      }
    }

    stage('Destroy') {
      when {
        expression { params.ACTION == 'destroy' }
      }
      steps {
        sh 'terraform destroy -auto-approve'
      }
    }
  }
}
